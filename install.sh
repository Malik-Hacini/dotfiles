#!/usr/bin/env bash
# ============================================================
# Dotfiles Bootstrap Script
# ============================================================
# Usage: git clone <your-repo> ~/dotfiles && cd ~/dotfiles && ./install.sh
#
# This script:
#   1. Installs required system packages (apt)
#   2. Adds PPAs for Neovim, Fish, Alacritty
#   3. Installs tools not in apt (starship, zoxide, yazi, lazygit, fzf, neovim)
#   4. Installs Node.js via NodeSource (needed by Neovim plugins)
#   5. Installs Python tools for Neovim (ipython, jupytext, black, isort, pylint)
#   6. Builds suckless tabbed (for zathura-tabbed)
#   7. Installs Nerd Fonts
#   8. Sets fish as the default shell
#   9. Stows all config packages
# ============================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$DOTFILES_DIR/install.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ─── Step 1: Add PPAs ───────────────────────────────────────
add_ppas() {
    info "Adding PPAs..."

    # Neovim unstable PPA (Ubuntu apt ships ancient 0.7.x)
    if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>&1 | tee -a "$LOG_FILE"
        log "Neovim PPA added."
    else
        warn "Neovim PPA already present."
    fi

    # Fish shell PPA (Ubuntu apt ships old 3.x)
    if ! grep -q "fish-shell/release-4" /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:fish-shell/release-4 2>&1 | tee -a "$LOG_FILE"
        log "Fish PPA added."
    else
        warn "Fish PPA already present."
    fi

    # Alacritty PPA (not in Ubuntu repos at all)
    if ! grep -q "aslatter/ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:aslatter/ppa 2>&1 | tee -a "$LOG_FILE"
        log "Alacritty PPA added."
    else
        warn "Alacritty PPA already present."
    fi

    # NodeSource for Node.js LTS (needed by nvim markdown-preview, mason LSPs)
    if ! command -v node &>/dev/null; then
        info "Adding NodeSource repository for Node.js LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>&1 | tee -a "$LOG_FILE"
        log "NodeSource repo added."
    else
        warn "Node.js already installed ($(node --version)), skipping NodeSource setup."
    fi
}

# ─── Step 2: Install system packages ────────────────────────
install_packages() {
    info "Updating package lists..."
    sudo apt update -y 2>&1 | tee -a "$LOG_FILE"

    info "Installing packages from packages.txt..."
    grep -v '^\s*#' "$DOTFILES_DIR/packages.txt" | grep -v '^\s*$' | \
        xargs sudo apt install -y 2>&1 | tee -a "$LOG_FILE"
    log "Base packages installed."

    # Install PPA packages separately (these require the PPAs added above)
    info "Installing PPA packages (neovim, fish, alacritty, nodejs)..."
    sudo apt install -y neovim fish alacritty nodejs 2>&1 | tee -a "$LOG_FILE"
    log "PPA packages installed."

    # Qutebrowser (used by typst-preview.nvim)
    info "Installing Qutebrowser..."
    sudo apt install -y qutebrowser 2>&1 | tee -a "$LOG_FILE"
    log "Qutebrowser installed."
}

# ─── Step 3: Install tools not in apt ────────────────────────
install_fzf() {
    if [ -d "$HOME/.fzf" ]; then
        warn "fzf already installed at ~/.fzf, skipping."
        return
    fi
    info "Installing fzf via git (apt version is severely outdated)..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" 2>&1 | tee -a "$LOG_FILE"
    "$HOME/.fzf/install" --bin 2>&1 | tee -a "$LOG_FILE"
    log "fzf installed to ~/.fzf."
}

install_starship() {
    if command -v starship &>/dev/null; then
        warn "Starship already installed, skipping."
        return
    fi
    info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y 2>&1 | tee -a "$LOG_FILE"
    log "Starship installed."
}

install_zoxide() {
    if command -v zoxide &>/dev/null; then
        warn "Zoxide already installed, skipping."
        return
    fi
    info "Installing Zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh 2>&1 | tee -a "$LOG_FILE"
    log "Zoxide installed."
}

install_yazi() {
    if command -v yazi &>/dev/null; then
        warn "Yazi already installed, skipping."
        return
    fi
    info "Installing Yazi..."
    local YAZI_VERSION
    YAZI_VERSION=$(curl -sL https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | head -1 | cut -d'"' -f4)
    if [ -z "$YAZI_VERSION" ]; then
        error "Could not determine latest Yazi version. Install manually."
        return
    fi
    local YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
    local TMP_DIR=$(mktemp -d)
    curl -sL "$YAZI_URL" -o "$TMP_DIR/yazi.zip"
    unzip -q "$TMP_DIR/yazi.zip" -d "$TMP_DIR"
    sudo mv "$TMP_DIR"/yazi-*/yazi /usr/local/bin/yazi
    sudo mv "$TMP_DIR"/yazi-*/ya /usr/local/bin/ya
    rm -rf "$TMP_DIR"
    log "Yazi installed."
}

install_lazygit() {
    if command -v lazygit &>/dev/null; then
        warn "Lazygit already installed, skipping."
        return
    fi
    info "Installing Lazygit..."
    local LAZYGIT_VERSION
    LAZYGIT_VERSION=$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
    if [ -z "$LAZYGIT_VERSION" ]; then
        error "Could not determine latest Lazygit version. Install manually."
        return
    fi
    local TMP_DIR=$(mktemp -d)
    curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -o "$TMP_DIR/lazygit.tar.gz"
    tar -xzf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR"
    sudo mv "$TMP_DIR/lazygit" /usr/local/bin/lazygit
    rm -rf "$TMP_DIR"
    log "Lazygit installed."
}

# ─── Step 4: Python tools for Neovim ────────────────────────
install_python_tools() {
    info "Installing Python tools for Neovim (ipython, jupytext, black, isort, pylint)..."
    pip3 install --user --break-system-packages \
        ipython \
        jupytext \
        black \
        isort \
        pylint \
        2>&1 | tee -a "$LOG_FILE" || {
        # Fallback: try without --break-system-packages (older pip)
        pip3 install --user \
            ipython \
            jupytext \
            black \
            isort \
            pylint \
            2>&1 | tee -a "$LOG_FILE"
    }
    log "Python tools installed."
}

# ─── Step 5: Build suckless tabbed ──────────────────────────
build_tabbed() {
    local TABBED_DIR="$DOTFILES_DIR/tabbed-src"
    local TABBED_BIN="$HOME/.local/bin/tabbed"

    if [ -x "$TABBED_BIN" ]; then
        warn "tabbed already exists at $TABBED_BIN, skipping build."
        return
    fi

    info "Building suckless tabbed (for zathura-tabbed)..."
    mkdir -p "$HOME/.local/bin"

    if [ -d "$TABBED_DIR" ]; then
        info "Using bundled tabbed source from $TABBED_DIR..."
        make -C "$TABBED_DIR" clean 2>&1 | tee -a "$LOG_FILE"
        make -C "$TABBED_DIR" 2>&1 | tee -a "$LOG_FILE"
        cp "$TABBED_DIR/tabbed" "$TABBED_BIN"
    else
        info "Cloning suckless tabbed..."
        local TMP_DIR=$(mktemp -d)
        git clone https://git.suckless.org/tabbed "$TMP_DIR/tabbed" 2>&1 | tee -a "$LOG_FILE"
        make -C "$TMP_DIR/tabbed" 2>&1 | tee -a "$LOG_FILE"
        cp "$TMP_DIR/tabbed/tabbed" "$TABBED_BIN"
        rm -rf "$TMP_DIR"
    fi

    chmod +x "$TABBED_BIN"
    log "tabbed built and installed to $TABBED_BIN."
}

# ─── Step 6: Install Nerd Fonts ─────────────────────────────
install_fonts() {
    local FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    local fonts=("JetBrainsMono" "RobotoMono" "NerdFontsSymbolsOnly")
    local NERD_FONT_VERSION
    NERD_FONT_VERSION=$(curl -sL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name"' | head -1 | cut -d'"' -f4)

    if [ -z "$NERD_FONT_VERSION" ]; then
        warn "Could not determine Nerd Fonts version. Using v3.3.0 as fallback."
        NERD_FONT_VERSION="v3.3.0"
    fi

    for font in "${fonts[@]}"; do
        if ls "$FONT_DIR"/*"${font}"* &>/dev/null 2>&1; then
            warn "Font $font already present, skipping."
            continue
        fi
        info "Installing Nerd Font: $font..."
        local TMP_DIR=$(mktemp -d)
        curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${font}.zip" -o "$TMP_DIR/$font.zip"
        unzip -qo "$TMP_DIR/$font.zip" -d "$FONT_DIR" -x "LICENSE*" "README*"
        rm -rf "$TMP_DIR"
        log "Font $font installed."
    done

    # Also install Font Awesome (used by polybar)
    if ls "$FONT_DIR"/*FontAwesome* &>/dev/null 2>&1 || ls "$FONT_DIR"/*"Font Awesome"* &>/dev/null 2>&1; then
        warn "Font Awesome already present, skipping."
    else
        info "Installing Font Awesome..."
        local FA_VERSION
        FA_VERSION=$(curl -sL https://api.github.com/repos/FortAwesome/Font-Awesome/releases/latest | grep '"tag_name"' | head -1 | cut -d'"' -f4)
        if [ -n "$FA_VERSION" ]; then
            local TMP_DIR=$(mktemp -d)
            curl -sL "https://github.com/FortAwesome/Font-Awesome/releases/download/${FA_VERSION}/fontawesome-free-${FA_VERSION}-desktop.zip" -o "$TMP_DIR/fa.zip"
            unzip -qo "$TMP_DIR/fa.zip" -d "$TMP_DIR"
            cp "$TMP_DIR"/fontawesome-free-*/otfs/*.otf "$FONT_DIR/" 2>/dev/null || true
            rm -rf "$TMP_DIR"
            log "Font Awesome installed."
        else
            warn "Could not determine Font Awesome version. Install manually."
        fi
    fi

    fc-cache -fv 2>&1 | tee -a "$LOG_FILE"
    log "Font cache rebuilt."
}

# ─── Step 7: Set fish as default shell ──────────────────────
set_fish_shell() {
    local FISH_PATH
    FISH_PATH=$(which fish 2>/dev/null || echo "")
    if [ -z "$FISH_PATH" ]; then
        error "Fish shell not found. Skipping shell change."
        return
    fi

    if [ "$SHELL" = "$FISH_PATH" ]; then
        warn "Fish is already the default shell."
        return
    fi

    # Ensure fish is in /etc/shells
    if ! grep -q "$FISH_PATH" /etc/shells; then
        info "Adding fish to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi

    info "Setting fish as default shell..."
    chsh -s "$FISH_PATH"
    log "Default shell set to fish. Log out and back in for it to take effect."
}

# ─── Step 8: Stow all packages ─────────────────────────────
stow_packages() {
    info "Stowing dotfiles packages..."

    # List of all stow packages (directories containing configs)
    local packages=(
        bash
        fish
        starship
        git
        i3
        polybar
        picom
        rofi
        dunst
        alacritty
        nvim
        yazi
        zathura
        lazygit
        fontconfig
        neofetch
        htop
        qutebrowser
        xdg-desktop-portal
        xdg-desktop-portal-termfilechooser
        latex
        scripts
        wallpapers
    )

    # Ensure target directories exist (stow needs the parent directories)
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"

    local failed=()
    for pkg in "${packages[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            info "Stowing $pkg..."
            if stow -v -d "$DOTFILES_DIR" -t "$HOME" --no-folding "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
                log "$pkg stowed."
            else
                warn "$pkg had conflicts. Trying with --adopt..."
                stow -v -d "$DOTFILES_DIR" -t "$HOME" --adopt --no-folding "$pkg" 2>&1 | tee -a "$LOG_FILE"
                # After adopt, restow to ensure dotfiles version wins
                git -C "$DOTFILES_DIR" checkout -- "$pkg/" 2>/dev/null || true
                stow -v -R -d "$DOTFILES_DIR" -t "$HOME" --no-folding "$pkg" 2>&1 | tee -a "$LOG_FILE"
                log "$pkg stowed (adopted existing files)."
            fi
        else
            warn "Package directory $pkg not found, skipping."
            failed+=("$pkg")
        fi
    done

    if [ ${#failed[@]} -gt 0 ]; then
        warn "Failed/skipped packages: ${failed[*]}"
    fi

    log "All packages stowed."
}

# ─── Step 9: Install Yazi plugins ───────────────────────────
install_yazi_plugins() {
    if command -v ya &>/dev/null; then
        info "Installing Yazi plugins..."
        ya pack -i 2>&1 | tee -a "$LOG_FILE" || warn "Yazi plugin install failed (non-critical)."
        log "Yazi plugins installed."
    else
        warn "ya (Yazi CLI) not found, skipping plugin install."
    fi
}

# ─── Main ───────────────────────────────────────────────────
main() {
    echo ""
    echo "============================================"
    echo "  Dotfiles Bootstrap Installer"
    echo "============================================"
    echo ""

    if [ "$DOTFILES_DIR" != "$HOME/dotfiles" ]; then
        warn "Dotfiles directory is at $DOTFILES_DIR (expected ~/dotfiles)."
        warn "Stow will target $HOME regardless."
    fi

    echo "" > "$LOG_FILE"

    # Parse arguments
    local SKIP_PACKAGES=false
    local SKIP_FONTS=false
    local SKIP_TOOLS=false
    local STOW_ONLY=false

    for arg in "$@"; do
        case $arg in
            --skip-packages) SKIP_PACKAGES=true ;;
            --skip-fonts)    SKIP_FONTS=true ;;
            --skip-tools)    SKIP_TOOLS=true ;;
            --stow-only)     STOW_ONLY=true ;;
            --help|-h)
                echo "Usage: ./install.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --skip-packages   Skip apt package installation (and PPAs)"
                echo "  --skip-fonts      Skip Nerd Font installation"
                echo "  --skip-tools      Skip tool installation (starship, zoxide, yazi, lazygit, fzf, python tools)"
                echo "  --stow-only       Only run stow (skip all installations)"
                echo "  --help            Show this help message"
                echo ""
                echo "What gets installed:"
                echo "  PPAs:      Neovim (unstable), Fish (release-4), Alacritty, NodeSource LTS"
                echo "  APT:       i3, polybar, picom, rofi, dunst, flameshot, zathura, texlive-full, etc."
                echo "  Binaries:  starship, zoxide, yazi, lazygit, fzf"
                echo "  Python:    ipython, jupytext, black, isort, pylint"
                echo "  Build:     suckless tabbed (for zathura-tabbed)"
                echo "  Fonts:     JetBrainsMono, RobotoMono, NerdFontsSymbolsOnly, Font Awesome"
                exit 0
                ;;
            *)
                error "Unknown option: $arg"
                exit 1
                ;;
        esac
    done

    if [ "$STOW_ONLY" = true ]; then
        stow_packages
        echo ""
        log "Stow-only mode complete."
        return
    fi

    if [ "$SKIP_PACKAGES" = false ]; then
        add_ppas
        install_packages
    else
        warn "Skipping package installation."
    fi

    if [ "$SKIP_TOOLS" = false ]; then
        install_fzf
        install_starship
        install_zoxide
        install_yazi
        install_lazygit
        install_python_tools
        build_tabbed
    else
        warn "Skipping tool installation."
    fi

    if [ "$SKIP_FONTS" = false ]; then
        install_fonts
    else
        warn "Skipping font installation."
    fi

    set_fish_shell
    stow_packages
    install_yazi_plugins

    echo ""
    echo "============================================"
    echo "  Installation Complete!"
    echo "============================================"
    echo ""
    info "Next steps:"
    echo "  1. Log out and back in (for fish shell to take effect)"
    echo "  2. Open Neovim and run :Lazy sync to install plugins"
    echo "  3. Review the README for manual setup items (Zen Browser, CUDA, etc.)"
    echo ""
    info "To unstow a package:  stow -D <package>"
    info "To restow a package:  stow -R <package>"
    info "Full log at: $LOG_FILE"
    echo ""
}

main "$@"
