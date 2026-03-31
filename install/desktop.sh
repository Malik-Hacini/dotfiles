#!/usr/bin/env bash

install_fonts() {
    info "Installing Fonts..."
    local FONT_DIR="$HOME/.local/share/fonts"
    local had_failure=false

    if ! mkdir -p "$FONT_DIR"; then
        error "Failed to create font directory at $FONT_DIR"
        return 1
    fi

    local fonts=("JetBrainsMono" "RobotoMono" "NerdFontsSymbolsOnly")
    local NERD_FONT_VERSION="v3.3.0"

    for font in "${fonts[@]}"; do
        if ls "$FONT_DIR"/*"${font}"* &>/dev/null 2>&1; then
            warn "Font $font already present, skipping."
            continue
        fi
        info "Downloading Nerd Font: $font..."
        local TMP_DIR
        TMP_DIR=$(mktemp -d)

        if ! curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${font}.zip" -o "$TMP_DIR/$font.zip"; then
            warn "Failed to download font $font."
            had_failure=true
            rm -rf "$TMP_DIR"
            continue
        fi

        if ! unzip -qo "$TMP_DIR/$font.zip" -d "$FONT_DIR" -x "LICENSE*" "README*"; then
            warn "Failed to extract font $font."
            had_failure=true
            rm -rf "$TMP_DIR"
            continue
        fi

        rm -rf "$TMP_DIR"
        log "Font $font installed."
    done

    # Update cache
    if command -v fc-cache &>/dev/null; then
        if fc-cache -fv; then
            log "Font cache rebuilt."
        else
            warn "Failed to rebuild font cache."
            had_failure=true
        fi
    fi

    if [ "$had_failure" = true ]; then
        return 1
    fi
}

ensure_system_service() {
    local service=$1
    local force_enable=${2:-false}
    local current_dm_target current_dm_unit
    local -a enable_cmd=(enable)

    if ! has_cmd systemctl; then
        warn "systemctl not found; skipping system service setup for $service."
        return 1
    fi

    if ! sudo systemctl is-enabled --quiet "$service"; then
        if [ "$force_enable" = true ] && sudo test -L /etc/systemd/system/display-manager.service; then
            current_dm_target=$(sudo readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)
            current_dm_unit=$(basename "$current_dm_target")

            if [ -n "$current_dm_unit" ] && [ "$current_dm_unit" != "$service" ]; then
                info "Replacing existing display manager service: $current_dm_unit -> $service"
                sudo systemctl disable "$current_dm_unit" >/dev/null 2>&1 || true
            fi

            enable_cmd+=(--force)
        fi

        info "Enabling system service: $service"
        if ! sudo systemctl "${enable_cmd[@]}" "$service"; then
            warn "Failed to enable system service $service."
            return 1
        fi
    fi

    return 0
}

configure_arch_desktop_services() {
    [ "$DISTRO_FAMILY" = arch ] || return 0
    ensure_system_service sddm.service true
}

generate_sddm_background() {
    local wallpaper=$1
    local theme_dst=$2
    local image_cmd
    local tmp_dir
    local background_tmp

    if [ ! -f "$wallpaper" ]; then
        warn "Wallpaper not found at $wallpaper; SDDM will fall back to a plain dark background."
        return 0
    fi

    if has_cmd magick; then
        image_cmd=magick
    elif has_cmd convert; then
        image_cmd=convert
    else
        warn "ImageMagick not found; SDDM will fall back to a plain dark background."
        return 0
    fi

    tmp_dir=$(mktemp -d)
    background_tmp="$tmp_dir/background-blur.jpg"

    if ! "$image_cmd" "$wallpaper" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x24 "$background_tmp"; then
        warn "Failed to generate blurred SDDM background from wallpaper."
        rm -rf "$tmp_dir"
        return 0
    fi

    if ! sudo install -m 0644 "$background_tmp" "$theme_dst/background-blur.jpg"; then
        warn "Failed to install blurred SDDM background image."
        rm -rf "$tmp_dir"
        return 0
    fi

    rm -rf "$tmp_dir"
    log "Blurred SDDM background generated from wallpaper."
}

install_sddm_theme() {
    local theme_src="$DOTFILES_DIR/sddm/usr/share/sddm/themes/tagarchy"
    local theme_dst="/usr/share/sddm/themes/tagarchy"
    local conf_src="$DOTFILES_DIR/sddm/etc/sddm.conf.d/zz-tagarchy-theme.conf"
    local conf_dst="/etc/sddm.conf.d/zz-tagarchy-theme.conf"
    local wallpaper="$HOME/Pictures/Wallpapers/catppuccin_gyro.jpg"
    local repo_wallpaper="$DOTFILES_DIR/wallpapers/Pictures/Wallpapers/catppuccin_gyro.jpg"

    [ "$DISTRO_FAMILY" = arch ] || return 0

    if ! has_cmd sddm; then
        warn "SDDM is not installed; skipping Tagarchy theme install."
        return 0
    fi

    if [ ! -d "$theme_src" ] || [ ! -f "$conf_src" ]; then
        error "Missing tracked SDDM theme files under $DOTFILES_DIR/sddm."
        return 1
    fi

    info "Installing Tagarchy SDDM theme..."

    if ! sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d; then
        error "Failed to create SDDM theme/config directories."
        return 1
    fi

    if ! sudo rm -rf "$theme_dst"; then
        error "Failed to replace existing Tagarchy SDDM theme directory."
        return 1
    fi

    if ! sudo cp -r "$theme_src" "$theme_dst"; then
        error "Failed to install Tagarchy SDDM theme files."
        return 1
    fi

    if ! sudo cp "$conf_src" "$conf_dst"; then
        error "Failed to install SDDM theme selection config."
        return 1
    fi

    if [ ! -f "$wallpaper" ] && [ -f "$repo_wallpaper" ]; then
        wallpaper="$repo_wallpaper"
    fi

    generate_sddm_background "$wallpaper" "$theme_dst"

    log "Tagarchy SDDM theme installed."
}

set_wallpaper() {
    local wallpaper="$HOME/Pictures/Wallpapers/catppuccin_gyro.jpg"
    local fehbg="$HOME/.fehbg"
    local theme_switch="$HOME/.local/bin/theme-switch"

    if [ ! -f "$wallpaper" ]; then
        warn "Wallpaper not found at $wallpaper"
        return
    fi

    if [ -x "$theme_switch" ] && command -v wal &>/dev/null; then
        if "$theme_switch" --no-reload --theme catppuccin-mocha --set-wallpaper "$wallpaper"; then
            log "Initial pywal16 theme applied."
            return 0
        fi

        warn "Failed to seed pywal16 theme; falling back to direct wallpaper setup."
    fi

    if ! command -v feh &>/dev/null; then
        warn "feh not found; skipping wallpaper setup."
        return
    fi

    if ! mkdir -p "$(dirname "$fehbg")"; then
        warn "Failed to prepare wallpaper launcher directory."
        return 1
    fi

    if ! printf '#!/usr/bin/env sh\nfeh --no-fehbg --bg-fill "%s"\n' "$wallpaper" > "$fehbg"; then
        warn "Failed to write $fehbg."
        return 1
    fi

    chmod +x "$fehbg"

    if [ -z "${DISPLAY:-}" ]; then
        info "No DISPLAY detected; wallpaper launcher written to $fehbg and will apply on graphical login."
        return
    fi

    if "$fehbg"; then
        log "Wallpaper set via feh."
    else
        warn "Failed to set wallpaper."
        return 1
    fi
}

set_default_mime_handler() {
    local desktop_entry=$1
    shift
    local mime_type
    local had_failure=false

    for mime_type in "$@"; do
        if ! xdg-mime default "$desktop_entry" "$mime_type"; then
            warn "Failed to set $desktop_entry as the default handler for $mime_type."
            had_failure=true
        fi
    done

    [ "$had_failure" = false ]
}

set_default_browser() {
    local had_failure=false
    local browser_mimes=(
        text/html
        text/xml
        application/xhtml+xml
        application/xml
        x-scheme-handler/http
        x-scheme-handler/https
        x-scheme-handler/ftp
    )

    if [ ! -x "$HOME/.local/bin/zen" ] && ! command -v zen &>/dev/null; then
        warn "Zen Browser is not installed; skipping default browser configuration."
        return 0
    fi

    if ! set_default_mime_handler zen.desktop "${browser_mimes[@]}"; then
        had_failure=true
    fi

    if command -v xdg-settings &>/dev/null; then
        if ! xdg-settings set default-web-browser zen.desktop; then
            warn "Failed to set Zen Browser as the desktop default web browser."
        fi
    fi

    [ "$had_failure" = false ]
}

set_default_file_manager() {
    if ! command -v yazi &>/dev/null; then
        warn "Yazi is not installed; skipping default file manager configuration."
        return 0
    fi

    set_default_mime_handler yazi.desktop inode/directory
}

configure_mime() {
    info "Configuring MIME types..."
    local had_failure=false
    local pdf_mimes=(
        application/pdf
        application/x-pdf
        application/acrobat
        application/vnd.pdf
        text/pdf
        text/x-pdf
    )
    local image_mimes=(image/jpeg image/png image/gif image/bmp image/tiff image/webp)

    if ! command -v xdg-mime &>/dev/null; then
        warn "xdg-mime not found."
        return
    fi

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi

    if ! set_default_mime_handler zathura-tabbed.desktop "${pdf_mimes[@]}"; then
        warn "Failed to fully configure Zathura as the default PDF handler."
        had_failure=true
    fi

    if ! set_default_mime_handler sxiv-tabbed.desktop "${image_mimes[@]}"; then
        warn "Failed to fully configure Sxiv as the default image handler."
        had_failure=true
    fi

    if ! set_default_browser; then
        warn "Failed to fully configure Zen Browser as the default browser."
        had_failure=true
    fi

    if ! set_default_file_manager; then
        warn "Failed to configure Yazi as the default file manager."
        had_failure=true
    fi

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi
    log "MIME types configured."

    if [ "$had_failure" = true ]; then
        return 1
    fi
}

install_desktop_extras() {
    local fonts_enabled=$1

    [ "$fonts_enabled" = true ] && run_step "font installation" install_fonts
    [ "$DISTRO_FAMILY" = arch ] && run_step "SDDM theme install" install_sddm_theme
    run_step "wallpaper setup" set_wallpaper
    run_step "MIME configuration" configure_mime
}
