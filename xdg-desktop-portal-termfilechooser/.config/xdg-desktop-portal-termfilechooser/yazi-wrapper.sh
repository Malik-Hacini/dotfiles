#!/bin/sh
# Wrapper script for xdg-desktop-portal-termfilechooser -> yazi (in alacritty)
# Launched by the portal service when a GTK app (e.g. Zen Browser) opens a file dialog.
#
# The portal service inherits this script's stdio. Yazi and ueberzugpp emit
# terminal graphics escape sequences (Kitty protocol, DEC private modes) that
# the portal's VTE parser cannot handle, causing parse errors and slowdowns.
# We must fully redirect stdio away from the portal and ensure the alacritty
# process runs with the correct graphical environment.

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

# ---------- Environment hardening ----------
# The portal service runs under systemd --user and may be missing critical
# variables that a normal interactive login shell would have. We explicitly
# source / set the ones required for yazi, ueberzugpp, and alacritty to
# function correctly with GPU-accelerated image previews.

# X11 / display -- required for alacritty and ueberzugpp
export DISPLAY="${DISPLAY:-:1}"
export XAUTHORITY="${XAUTHORITY:-/run/user/$(id -u)/gdm/Xauthority}"

# XDG runtime (D-Bus, etc.)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

# Session type -- ueberzugpp needs to know we're on X11
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"

# Terminal capabilities -- ensure yazi detects a capable terminal
export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"

# CUDA / GPU libraries (user has CUDA installed; needed for GPU-accelerated rendering)
if [ -d /usr/local/cuda-12.8 ]; then
    export CUDA_HOME="${CUDA_HOME:-/usr/local/cuda-12.8}"
    export CUDA_PATH="${CUDA_PATH:-/usr/local/cuda-12.8}"
    export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# PATH -- ensure yazi, ueberzugpp, fzf, fish, and other tools are findable
# Merge the user's typical PATH entries with whatever the portal inherited.
for p in \
    "$HOME/.local/bin" \
    "$HOME/.fzf/bin" \
    "/usr/local/bin" \
    "/usr/local/sbin" \
    "/usr/bin" \
    "/usr/sbin"
do
    case ":$PATH:" in
        *":$p:"*) ;; # already present
        *) PATH="$p:$PATH" ;;
    esac
done
export PATH

# HOME fallback (should always be set, but be defensive)
export HOME="${HOME:-$(eval echo ~"$(id -un)")}"

# ---------- Build yazi arguments ----------
chooser_args=""
cwd_out=""

if [ "$save" = "1" ]; then
    chooser_args="--chooser-file='$out' '$path'"
elif [ "$directory" = "1" ]; then
    cwd_out="${out}.1"
    chooser_args="--chooser-file='$out' --cwd-file='$cwd_out' '$path'"
elif [ "$multiple" = "1" ]; then
    chooser_args="--chooser-file='$out' '$path'"
else
    chooser_args="--chooser-file='$out' '$path'"
fi

# ---------- Launch alacritty ----------
# Key design decisions:
#   1. Redirect stdin/stdout/stderr to /dev/null so the portal process never
#      receives yazi's terminal escape sequences (fixes parse errors & slowdown).
#   2. Use alacritty's --title flag so the window is identifiable in i3.
#   3. Use fish -l (login) to ensure fish loads config.fish and all user
#      environment (zoxide, aliases, etc.), then exec yazi within it.
#   4. The script *blocks* until alacritty exits (no backgrounding) because
#      the portal must wait for the chooser file to be written.

alacritty \
    --title "File Chooser" \
    -e fish -l -c "yazi $chooser_args" \
    </dev/null >/dev/null 2>&1

# ---------- Directory mode: fallback to cwd-file ----------
if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$cwd_out" ]; then
        cat "$cwd_out" > "$out"
    fi
    rm -f "$cwd_out"
fi
