#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export DOTFILES_DIR
export STOW_LIST_FILE="$DOTFILES_DIR/packages/stow_list.omarchy.txt"
export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"

info() { printf '[INFO] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1" >&2; }
log() { printf '[OK] %s\n' "$1"; }

show_help() {
    cat <<'EOF'
Usage: ./install-omarchy.sh

Install missing personal tools, apply the Omarchy Stow profile, and activate
the user integrations. The operation is idempotent and has no optional flags.
EOF
}

if (($#)); then
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            show_help >&2
            exit 1
            ;;
    esac
fi

if ((EUID == 0)); then
    printf '%s\n' "Run this installer as your normal user, not as root." >&2
    exit 1
fi

if ! command -v omarchy >/dev/null 2>&1 || [[ ! -d $OMARCHY_PATH ]]; then
    printf '%s\n' "This installer requires an Omarchy system." >&2
    exit 1
fi

read_packages() {
    local list=$1
    while IFS= read -r package; do
        case "$package" in
            ''|'#'*) continue ;;
        esac
        printf '%s\n' "$package"
    done < "$list"
}

install_packages() {
    local package
    local -a missing=()

    while IFS= read -r package; do
        pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
    done < <(read_packages "$DOTFILES_DIR/packages/omarchy.arch.txt")

    if ((${#missing[@]})); then
        omarchy pkg add "${missing[@]}"
    fi

    missing=()
    while IFS= read -r package; do
        pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
    done < <(read_packages "$DOTFILES_DIR/packages/omarchy.aur.arch.txt")

    if ((${#missing[@]})); then
        omarchy pkg aur add "${missing[@]}"
    fi

    if ! command -v zen-browser >/dev/null 2>&1; then
        omarchy install browser zen
    fi
}

install_user_tools() {
    local tool

    if command -v pipx >/dev/null 2>&1; then
        for tool in ipython jupytext black isort pylint; do
            pipx list --short 2>/dev/null | grep -qE "^${tool}([[:space:]]|$)" || pipx install "$tool"
        done
    fi

    if command -v juliaup >/dev/null 2>&1; then
        juliaup status 2>/dev/null | grep -qE '(^|[[:space:]])release([[:space:]]|$)' || juliaup add release
        juliaup default release
    fi

    if [[ ! -d $HOME/.tmux/plugins/tpm/.git ]]; then
        mkdir -p "$HOME/.tmux/plugins"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

stow_dotfiles() {
    source "$DOTFILES_DIR/install/stow_helpers.sh"

    load_stow_packages "$DOTFILES_DIR"
    STOW_DRY_RUN=false
    STOW_BACKUP_DIR=${STOW_BACKUP_DIR:-$HOME/dotfiles-stow-backup-$(date +%F-%H%M%S)}

    # Omarchy ships a complete LazyVim tree. Back it up as one unit so files
    # absent from the personal Neovim package cannot remain active afterward.
    if [[ -f $HOME/.config/nvim/lazyvim.json && ! -L $HOME/.config/nvim/init.lua ]]; then
        backup_stow_target "$HOME/.config/nvim"
    fi

    force_stow_packages "$DOTFILES_DIR" "${STOW_PACKAGE_LIST[@]}"
}

install_tmux_plugins() {
    local installer="$HOME/.tmux/plugins/tpm/bin/install_plugins"

    if [[ -x $installer ]]; then
        "$installer"
    else
        warn "TPM plugin installer was not found at $installer"
    fi
}

activate_integrations() {
    omarchy default terminal kitty
    omarchy default browser zen
    omarchy default editor nvim
    omarchy theme refresh
    install_tmux_plugins

    # Reuse the portable MIME setup without invoking any legacy desktop setup.
    source "$DOTFILES_DIR/install/desktop.sh"
    configure_mime

    if systemctl --user daemon-reload; then
        systemctl --user enable zen-dotfiles-profile.path tmux.service
        systemctl --user start zen-dotfiles-profile.path
        if ! tmux has-session 2>/dev/null; then
            systemctl --user start tmux.service
        fi
        systemctl --user restart xdg-desktop-portal.service
        systemctl --user restart xdg-desktop-portal-termfilechooser.service
    else
        warn "User systemd is unavailable; services will activate on the next graphical login."
    fi

    if command -v nvim >/dev/null 2>&1; then
        nvim --headless "+Lazy! sync" +qa
    fi
}

install_packages
install_user_tools
stow_dotfiles
activate_integrations
