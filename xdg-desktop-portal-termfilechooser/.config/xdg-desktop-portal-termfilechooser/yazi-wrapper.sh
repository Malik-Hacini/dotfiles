#!/bin/sh
# Wrapper script for xdg-desktop-portal-termfilechooser -> yazi
# Launched by the portal service when a GTK app (e.g. Zen Browser) opens a file dialog.
#
# The portal service inherits this script's stdio. Yazi and its image preview
# adapters emit terminal graphics escape sequences (Kitty protocol, DEC private modes) that
# the portal's VTE parser cannot handle, causing parse errors and slowdowns.
# We fully redirect stdio away from the portal and ensure the terminal runs with
# a valid graphical/session environment.

set -e

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"
verbosity="${6:-0}"

if [ "$verbosity" -ge 4 ] 2>/dev/null; then
    set -x
fi

# Keep HOME available even in sparse systemd user environments.
export HOME="${HOME:-$(eval echo ~"$(id -un)")}"

# Read values from the systemd --user activation environment when available.
systemd_env=""
if command -v systemctl >/dev/null 2>&1; then
    systemd_env="$(systemctl --user show-environment 2>/dev/null || true)"
fi

systemd_env_get() {
    key="$1"
    printf '%s\n' "$systemd_env" | awk -F= -v key="$key" '$1 == key { print substr($0, length(key) + 2); exit }'
}

# Import GUI/session variables from systemd if missing in current process.
if [ -z "${DISPLAY:-}" ]; then
    display="$(systemd_env_get DISPLAY)"
    if [ -n "$display" ]; then
        export DISPLAY="$display"
    else
        socket_count=0
        detected_display=""
        for socket in /tmp/.X11-unix/X*; do
            [ -S "$socket" ] || continue
            socket_count=$((socket_count + 1))
            detected_display=":${socket##*/X}"
            [ "$socket_count" -gt 1 ] && break
        done
        if [ "$socket_count" -eq 1 ] && [ -n "$detected_display" ]; then
            export DISPLAY="$detected_display"
        fi
    fi
fi

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    wayland_display="$(systemd_env_get WAYLAND_DISPLAY)"
    if [ -n "$wayland_display" ]; then
        export WAYLAND_DISPLAY="$wayland_display"
    fi
fi

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    runtime_dir="$(systemd_env_get XDG_RUNTIME_DIR)"
    if [ -z "$runtime_dir" ]; then
        runtime_dir="/run/user/$(id -u)"
    fi
    export XDG_RUNTIME_DIR="$runtime_dir"
fi

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    dbus_address="$(systemd_env_get DBUS_SESSION_BUS_ADDRESS)"
    if [ -z "$dbus_address" ] && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
        dbus_address="unix:path=${XDG_RUNTIME_DIR}/bus"
    fi
    if [ -n "$dbus_address" ]; then
        export DBUS_SESSION_BUS_ADDRESS="$dbus_address"
    fi
fi

if [ -z "${XDG_SESSION_TYPE:-}" ]; then
    session_type="$(systemd_env_get XDG_SESSION_TYPE)"
    if [ -z "$session_type" ]; then
        if [ -n "${WAYLAND_DISPLAY:-}" ]; then
            session_type="wayland"
        elif [ -n "${DISPLAY:-}" ]; then
            session_type="x11"
        fi
    fi
    if [ -n "$session_type" ]; then
        export XDG_SESSION_TYPE="$session_type"
    fi
fi

if [ -z "${XDG_CURRENT_DESKTOP:-}" ]; then
    current_desktop="$(systemd_env_get XDG_CURRENT_DESKTOP)"
    if [ -n "$current_desktop" ]; then
        export XDG_CURRENT_DESKTOP="$current_desktop"
    fi
fi

if [ -z "${XAUTHORITY:-}" ]; then
    xauthority="$(systemd_env_get XAUTHORITY)"
    if [ -z "$xauthority" ] && [ -f "$HOME/.Xauthority" ]; then
        xauthority="$HOME/.Xauthority"
    fi
    if [ -z "$xauthority" ] && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
        for candidate in "$XDG_RUNTIME_DIR/Xauthority" "$XDG_RUNTIME_DIR"/*/Xauthority; do
            if [ -f "$candidate" ]; then
                xauthority="$candidate"
                break
            fi
        done
    fi
    if [ -n "$xauthority" ] && [ -f "$xauthority" ]; then
        export XAUTHORITY="$xauthority"
    fi
fi

# Terminal capabilities - ensure yazi detects a capable terminal.
export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"

# PATH - merge common user/system locations without hardcoding a specific machine.
for p in \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.fzf/bin" \
    "/usr/local/bin" \
    "/usr/local/sbin" \
    "/usr/bin" \
    "/usr/sbin"
do
    case ":${PATH:-}:" in
        *":$p:"*) ;;
        *) PATH="$p${PATH:+:$PATH}" ;;
    esac
done
export PATH

# Build yazi arguments.
cwd_out=""
set -- --chooser-file="$out"

if [ "$directory" = "1" ]; then
    cwd_out="${out}.1"
    set -- "$@" --cwd-file="$cwd_out"
fi

if [ -n "$path" ]; then
    set -- "$@" "$path"
fi

# Launch the selected XDG terminal. Redirect all stdio so the portal does not parse
# terminal control sequences coming from yazi image previews.
termcmd="${TERMCMD:-xdg-terminal-exec}"

if command -v yazi >/dev/null 2>&1; then
    "$termcmd" \
        yazi "$@" \
        </dev/null >/dev/null 2>&1
elif command -v fish >/dev/null 2>&1; then
    "$termcmd" \
        fish -l -c 'command -q yazi; and yazi $argv' "$@" \
        </dev/null >/dev/null 2>&1
else
    exit 127
fi

# Directory mode: fallback to cwd-file when chooser file is empty.
if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$cwd_out" ]; then
        cp "$cwd_out" "$out"
    fi
    rm -f "$cwd_out"
fi
