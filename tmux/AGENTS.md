# AGENTS.md

## Scope

This package owns tmux configuration under `tmux/.config/tmux/`.
Primary file: `tmux/.config/tmux/tmux.conf`.

## Purpose

This tmux setup is tightly coupled to the desktop session. It is responsible for keybindings, clipboard forwarding, passthrough behavior, environment refresh, and session persistence through TPM, resurrect, and continuum.

## Change Carefully

- Preserve GUI/session environment propagation; it keeps reattached sessions compatible with X11, clipboard tools, portals, and `i3-msg`.
- Do not remove `set-clipboard`, `allow-passthrough`, or `update-environment` behavior casually; they support OSC52 clipboard and terminal integrations.
- Keep startup logic resilient to missing tools and empty resurrect state.
- Avoid edits in vendored plugin code under `tmux/.config/tmux/plugins/` unless absolutely necessary.
- Keep FR AZERTY keybindings unless intentionally changing keyboard ergonomics.

## Plugin And Vendor Guidance

The `plugins/` directory contains third-party code, especially Catppuccin and TPM-managed plugins.

- Prefer changing `tmux.conf` plugin variables instead of patching vendored files.
- If a plugin patch is unavoidable, document why and keep the change minimal.
- Treat plugin updates and local patches as separate concerns.

## Relevant Integrations

- Attaching terminals refresh tmux's session environment for new panes/windows
- `i3/.config/i3/config`: propagates the legacy X11 session environment
- `kitty/.config/kitty/kitty.conf`: outer terminal for clipboard/passthrough behavior
- `systemd/.config/systemd/user/tmux.service`: starts restore after the graphical session environment is ready

## Validation

After edits, validate with tmux itself:

- reload with `tmux source-file ~/.config/tmux/tmux.conf`
- verify no syntax/runtime errors appear
- test pane/window navigation and AZERTY window selection if touched
- if env logic changed, verify `DISPLAY`, `DBUS_SESSION_BUS_ADDRESS`, and `I3SOCK` are available in a reattached session
- if clipboard/passthrough changed, verify copy works from inside tmux in `kitty`
- if persistence changed, verify resurrect/continuum still behave sensibly
