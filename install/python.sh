#!/usr/bin/env bash

install_python_tools() {
    info "Installing Python tools via pipx..."
    local had_failure=false

    if ! command -v pipx &>/dev/null; then
        if [ "$INSTALL_PACKAGES" != true ]; then
            warn "pipx is not installed and package installation was skipped. Skipping Python tools."
            return 1
        fi

        info "Installing pipx..."
        if ! install_pkg "$(pipx_package_name)"; then
            error "Failed to install pipx."
            return 1
        fi
    fi
    
    # Ensure pipx path is available
    export PATH="$HOME/.local/bin:$PATH"

    local tools=(
        pywal16
        ipython
        jupytext
        black
        isort
        pylint
    )

    for tool in "${tools[@]}"; do
        if pipx list | grep -q "$tool"; then
            warn "$tool already installed via pipx."
        else
            info "Installing $tool..."
            if ! pipx install "$tool"; then
                warn "Failed to install $tool via pipx."
                had_failure=true
            fi
        fi
    done
    
    if ! pipx ensurepath; then
        warn "Failed to update the pipx PATH settings."
        had_failure=true
    fi

    if [ "$had_failure" = true ]; then
        return 1
    fi

    log "Python tools installed."
}

pipx_package_name() {
    case "$DISTRO_FAMILY" in
        arch)
            printf 'python-pipx\n'
            ;;
        *)
            printf 'pipx\n'
            ;;
    esac
}
