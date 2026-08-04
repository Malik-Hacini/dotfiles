#!/usr/bin/env bash

type info >/dev/null 2>&1 || info() { printf '[INFO] %s\n' "$1"; }
type warn >/dev/null 2>&1 || warn() { printf '[WARN] %s\n' "$1"; }
type log >/dev/null 2>&1 || log() { printf '[OK] %s\n' "$1"; }
type error >/dev/null 2>&1 || error() { printf '[ERROR] %s\n' "$1" >&2; }
type die >/dev/null 2>&1 || die() { error "$1"; exit 1; }

STOW_DRY_RUN=${STOW_DRY_RUN:-false}
STOW_BACKUP_DIR=${STOW_BACKUP_DIR:-}
STOW_IGNORE_PATTERN=${STOW_IGNORE_PATTERN:-^AGENTS\.md$}

declare -ag STOW_PACKAGE_LIST=()
declare -ag STOW_FAILED_PACKAGES=()
declare -Ag STOW_MOVED_TARGETS=()

resolve_stow_repo_dir() {
    for candidate in "${1:-}" "${DOTFILES_DIR:-}" "$PWD" "$HOME/dotfiles"; do
        [ -n "$candidate" ] || continue
        [ -f "$candidate/packages/stow_list.txt" ] && printf '%s\n' "$candidate" && return 0
    done

    return 1
}

load_stow_packages() {
    local repo_dir=$1
    local stow_list=${STOW_LIST_FILE:-$repo_dir/packages/stow_list.txt}

    [ -f "$stow_list" ] || die "Missing stow list: $stow_list"
    mapfile -t STOW_PACKAGE_LIST < <(grep -vE '^\s*#|^\s*$' "$stow_list")
}

run_logged() {
    if [ -n "${LOG_FILE:-}" ]; then
        "$@" 2>&1 | tee -a "$LOG_FILE"
        return "${PIPESTATUS[0]}"
    fi

    "$@"
}

ensure_stow_targets() {
    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/applications"
}

ensure_stow_backup_dir() {
    [ "$STOW_DRY_RUN" = true ] && return 0
    [ -n "$STOW_BACKUP_DIR" ] || STOW_BACKUP_DIR="$HOME/dotfiles-stow-backup-$(date +%F-%H%M%S)"
    mkdir -p "$STOW_BACKUP_DIR"
}

unique_stow_backup_path() {
    local path=$1
    local candidate=$path
    local suffix=1

    while [ -e "$candidate" ] || [ -L "$candidate" ]; do
        candidate="${path}.bak${suffix}"
        suffix=$((suffix + 1))
    done

    printf '%s\n' "$candidate"
}

record_stow_failure() {
    local package=$1
    local failed

    for failed in "${STOW_FAILED_PACKAGES[@]}"; do
        [ "$failed" = "$package" ] && return 0
    done

    STOW_FAILED_PACKAGES+=("$package")
}

backup_stow_target() {
    local target=$1
    local destination relative_path

    if [ -n "${STOW_MOVED_TARGETS[$target]+x}" ]; then
        return 0
    fi

    [ -n "$STOW_BACKUP_DIR" ] || STOW_BACKUP_DIR="$HOME/dotfiles-stow-backup-$(date +%F-%H%M%S)"
    relative_path=${target#"$HOME"/}
    destination=$(unique_stow_backup_path "$STOW_BACKUP_DIR/$relative_path") || return 1

    if [ "$STOW_DRY_RUN" = true ]; then
        info "[dry-run] Back up $target -> $destination"
        STOW_MOVED_TARGETS["$target"]=$destination
        return 0
    fi

    ensure_stow_backup_dir || return 1
    mkdir -p "$(dirname "$destination")" || return 1
    mv "$target" "$destination" || return 1
    STOW_MOVED_TARGETS["$target"]=$destination
    info "Backed up $target -> $destination"
}

ensure_stow_parent_directories() {
    local target=$1
    local current="$HOME"
    local parent relative_path
    local -a segments

    parent=$(dirname "$target")
    [ "$parent" = "$HOME" ] && return 0

    relative_path=${parent#"$HOME"/}
    IFS='/' read -r -a segments <<<"$relative_path"

    for segment in "${segments[@]}"; do
        current="$current/$segment"
        if { [ -e "$current" ] || [ -L "$current" ]; } && [ ! -d "$current" ]; then
            backup_stow_target "$current" || return 1
        fi
    done
}

prepare_stow_target() {
    local source=$1
    local package_dir=$2
    local target source_real target_real

    target="$HOME/${source#"$package_dir"/}"
    ensure_stow_parent_directories "$target" || return 1

    if [ -L "$target" ]; then
        source_real=$(readlink -f "$source" 2>/dev/null || printf '%s\n' "$source")
        target_real=$(readlink -f "$target" 2>/dev/null || printf '%s\n' "$target")
        [ "$source_real" = "$target_real" ] && return 0
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_stow_target "$target" || return 1
    fi
}

prepare_stow_package() {
    local repo_dir=$1
    local package=$2
    local package_dir="$repo_dir/$package"
    local source

    if [ ! -d "$package_dir" ]; then
        warn "Package directory $package not found, skipping."
        return 0
    fi

    info "Preparing targets for package: $package"
    # Skip files that are intentionally ignored or machine-local so we do not
    # back them up and leave them absent after the restow.
    while IFS= read -r -d '' source; do
        prepare_stow_target "$source" "$package_dir" || return 1
    done < <(find "$package_dir" -mindepth 1 \( -type f -o -type l \) ! -path "$package_dir/AGENTS.md" ! -name '.gitignore' ! -name 'mimeinfo.cache' -print0)
}

restow_package() {
    local repo_dir=$1
    local package=$2
    local -a command=(stow -R -d "$repo_dir" -t "$HOME" --no-folding "--ignore=$STOW_IGNORE_PATTERN" "$package")

    if [ "$STOW_DRY_RUN" = true ]; then
        # Simulate adoption so targets already scheduled for backup do not show
        # as false conflicts. Simulation mode never changes the repo or $HOME.
        command=(stow -n -R -v --adopt -d "$repo_dir" -t "$HOME" --no-folding "--ignore=$STOW_IGNORE_PATTERN" "$package")
        info "[dry-run] Restowing package: $package"
    else
        command=(stow -R -v -d "$repo_dir" -t "$HOME" --no-folding "--ignore=$STOW_IGNORE_PATTERN" "$package")
        info "Restowing package: $package"
    fi

    run_logged "${command[@]}"
}

force_stow_packages() {
    local repo_dir=$1
    shift
    local package

    ensure_stow_targets || return 1
    STOW_HAD_FAILURES=false
    STOW_FAILED_PACKAGES=()
    STOW_MOVED_TARGETS=()

    for package in "$@"; do
        if ! prepare_stow_package "$repo_dir" "$package"; then
            warn "Could not fully prepare targets for package: $package"
            record_stow_failure "$package"
        fi
    done

    for package in "$@"; do
        if ! restow_package "$repo_dir" "$package"; then
            warn "Failed to stow package: $package"
            record_stow_failure "$package"
        fi
    done

    if [ ${#STOW_FAILED_PACKAGES[@]} -eq 0 ]; then
        return 0
    fi

    STOW_HAD_FAILURES=true
    return 1
}
