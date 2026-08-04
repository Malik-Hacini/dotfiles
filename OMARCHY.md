# Omarchy Profile

This profile layers personal dotfiles onto Omarchy without replacing the parts Omarchy needs to update and theme dynamically.

## Ownership

Omarchy continues to own:

- the Omarchy shell, bar, launcher, and notifications
- GTK appearance, wallpaper, lock screen, idle behavior, and SDDM
- generated theme state under `~/.local/state/omarchy/current/`
- machine-local monitor configuration in `~/.config/hypr/monitors.lua`

This repository owns:

- personal Hyprland input, layout, and keybindings under `omarchy/.config/hypr/`
- application configuration selected by `packages/stow_list.omarchy.txt`
- user theme templates and hooks under `omarchy/.config/omarchy/`

Nothing under `/usr/share/omarchy/` is modified.

## Dynamic Themes

Omarchy's active `colors.toml` drives Neovim and the user templates for Zathura and Zen. Existing Omarchy integrations continue to recolor Kitty, btop, tmux, and supported applications. Neovim loads the shared palette adapter directly, avoiding theme-specific files that Omarchy copies into its generated state.

Run `omarchy theme refresh` after changing templates. The `theme-set` hook copies generated Zathura and Zen assets into their application config locations.

## Keybindings

Omarchy's complete default keymap remains active, including workspace, navigation, grouping, brightness, clipboard, screenshot, screen-recording, media, and hardware shortcuts. The personal i3 application aliases are layered on top, including `Super+Q` to close a window and `Super+Z/N/G/O/D/T/P/Slash` for personal applications and menus.

Five exact keys conflict with Omarchy defaults and are intentionally reassigned: `Super+G` (grouping), `Super+O` (pop-out), `Super+T` (floating), `Super+P` (pseudo), and `Super+Slash` (monitor scale up). The rest of Omarchy's bindings are unchanged. Run `omarchy menu keybindings` or press `Super+K` to search the complete active map.

Workspace-local PDF/image tab containers remain an i3-only feature and fall back to normal Zathura/imv windows on Wayland.

The optional Clipboard Project package is not installed because its current AUR source release does not build with GCC 16. Normal Wayland text clipboard support still comes from `wl-clipboard`; Yazi's optional `Ctrl+Y` file-copy plugin requires the missing `cb` executable.

## Installation

Run as the normal desktop user:

```bash
./install-omarchy.sh
```

Conflicting user files are moved to `~/dotfiles-stow-backup-<timestamp>/` before Stow creates links. The installer is repeatable: already installed packages, pipx tools, Julia, TPM, and user services are detected or updated idempotently.

For a no-change preview after installation:

```bash
force-stow-dotfiles --dry-run
```

On Omarchy, that command automatically selects `packages/stow_list.omarchy.txt`. The legacy `install.sh` refuses to run when Omarchy is detected so it cannot install i3/X11 components over this profile.

## Validation

After changing Hyprland files, run:

```bash
hyprctl reload
hyprctl configerrors
```

After changing theme templates, run:

```bash
omarchy theme refresh
```
