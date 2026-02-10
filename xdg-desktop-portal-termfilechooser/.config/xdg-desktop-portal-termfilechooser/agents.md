# Implementation Report: Yazi as File Picker in Zen Browser

## Objective
Configure `yazi` (running in `alacritty`) as the default file picker for GTK applications (specifically Zen Browser) on an Ubuntu system using i3 window manager.

## Architecture

```
Zen Browser (GTK_USE_PORTAL=1)
  -> D-Bus: org.freedesktop.impl.portal.FileChooser
  -> xdg-desktop-portal routes via portals.conf
  -> xdg-desktop-portal-termfilechooser (systemd user service)
  -> yazi-wrapper.sh (this config dir)
  -> alacritty -e fish -l -c "yazi --chooser-file=..."
  -> user selects file, yazi writes path to chooser-file
  -> portal reads the file and returns path to Zen Browser
```

## Files Modified / Created

### User-level (this directory)
| File | Purpose |
|------|---------|
| `yazi-wrapper.sh` | Launches alacritty+fish+yazi with correct env; redirects stdio away from portal |
| `config` | Portal config pointing `cmd=` to the wrapper script |
| `agents.md` | This documentation |

### System-level (installed from source)
| File | Purpose |
|------|---------|
| `/usr/local/libexec/xdg-desktop-portal-termfilechooser` | Portal backend binary |
| `/usr/local/lib/systemd/user/xdg-desktop-portal-termfilechooser.service` | systemd user service |
| `/usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.termfilechooser.service` | D-Bus activation |
| `/usr/share/xdg-desktop-portal/portals/termfilechooser.portal` | Portal definition (declares `UseIn=i3`) |

### Portal routing
| File | Purpose |
|------|---------|
| `~/.config/xdg-desktop-portal/portals.conf` | Routes `FileChooser` to termfilechooser, everything else to gtk |

### i3 integration
| File | Change |
|------|--------|
| `~/.config/i3/config` | `exec --no-startup-id systemctl --user import-environment && systemctl --user restart xdg-desktop-portal-termfilechooser.service` |

### Fish shell
| File | Change |
|------|--------|
| `~/.config/fish/config.fish` | `set -gx GTK_USE_PORTAL 1` (tells GTK apps to use portal for file dialogs) |

## Root Causes Found and Fixed

### 1. Portal stdio capture (PRIMARY cause of image preview bugs)
**Problem:** The portal binary spawned the wrapper script as a child process, inheriting its stdout/stderr. Yazi and ueberzugpp emit Kitty graphics protocol escape sequences and DEC private mode codes for image rendering. The portal's internal VTE parser received these sequences and attempted to parse them, producing thousands of `[PARSE ERROR] Unsupported screen mode: 2026 (private)` and `Malformed GraphicsCommand control block` errors. This created a feedback loop that slowed down yazi's image rendering significantly.

**Fix:** The wrapper script now redirects all three stdio streams away from the portal:
```sh
alacritty ... </dev/null >/dev/null 2>&1
```
This ensures alacritty gets its own PTY (which it always does as a terminal emulator), and the portal process never sees any escape sequences from yazi.

### 2. Environment variables missing from portal context
**Problem:** The portal service runs under systemd `--user`, which may start before the full desktop session environment is established. Critical variables like `DISPLAY`, `XAUTHORITY`, `COLORTERM`, `XDG_SESSION_TYPE`, and custom `PATH` entries were missing or stale, causing ueberzugpp to fail silently and yazi to fall back to slow/broken preview rendering.

**Fix (persistent):**
- i3 config imports the full environment into systemd on every login, then restarts the portal to pick it up
- The wrapper script has defensive fallback values for all critical variables
- Fish is launched with `-l` (login mode) so `config.fish` executes and sets `LD_LIBRARY_PATH`, `CUDA_*`, etc.

### 3. Missing portal routing configuration
**Problem:** Both `gnome` and `termfilechooser` portals claim to implement `FileChooser`. Without a `portals.conf`, the portal dispatcher could choose either one depending on startup order.

**Fix:** Created `~/.config/xdg-desktop-portal/portals.conf`:
```ini
[preferred]
default=gtk
org.freedesktop.impl.portal.FileChooser=termfilechooser
```

### 4. Argument quoting in wrapper script
**Problem:** The original wrapper used `$cmd $*` which breaks on file paths containing spaces (common in Downloads, Documents, etc.).

**Fix:** The rewritten wrapper properly quotes all arguments using single-quote wrapping within the fish command string.

## Debugging Commands

```sh
# Check portal service status
systemctl --user status xdg-desktop-portal-termfilechooser.service

# Check portal logs (look for parse errors or config issues)
journalctl --user -u xdg-desktop-portal-termfilechooser.service -f

# Check what environment the portal service has
systemctl --user show-environment | grep -E "DISPLAY|XAUTHORITY|PATH"

# Re-import environment and restart portal
systemctl --user import-environment && systemctl --user restart xdg-desktop-portal-termfilechooser.service

# Restart all portal services (nuclear option)
systemctl --user restart xdg-desktop-portal-termfilechooser.service xdg-desktop-portal.service

# Test file chooser from CLI (simulates what the portal does)
# This should open alacritty with yazi:
~/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh 0 0 0 "$HOME" /tmp/test-chooser-out
cat /tmp/test-chooser-out  # should contain the selected file path
```
