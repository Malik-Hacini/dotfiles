# Workstation Dotfiles
GNU Stow-managed dotfiles for an Omarchy/Hyprland workstation, with a legacy i3/X11 profile for standalone Ubuntu/Debian and Arch installs.

![Home screen](preview.png)
## System Overview

This repo is designed as one cohesive, keyboard-first environment you can apply on a fresh machine to immediately bootstrap a fully functional system.

The principles used for building this system are simple :

- Keyboard is King
- Distractions are evil
- Defaults are fine

The Omarchy profile keeps Hyprland, the Omarchy shell, notifications, lock screen, wallpaper, GTK, and SDDM under Omarchy's ownership. Personal application colors are generated from the active Omarchy theme.

- Omarchy desktop: `Hyprland`, Omarchy shell/menu, and Omarchy lock/screenshot tools
- Legacy desktop: `i3`, `picom`, `polybar`, `rofi`, `dunst`, and `i3lock-color`
- Terminal emulator: `foot` by default; `kitty` retained for Kitty-specific features
- Shell and prompt: `fish` and `starship`
- Terminal tools: `tmux`, `lazygit`, `zoxide`, `fzf`, and `yazi`
- Editing: `neovim` (see the [Neovim config README](nvim/.config/nvim/README.md) for details).
- Web: Zen Browser
- AI workflow: OpenCode agent, with integration in Neovim.
- Documents/media: workspace-local i3 tabs on X11; native standalone Zathura/imv windows on Wayland

The repository includes wallpaper assets under `wallpapers/Pictures/Wallpapers/`.


## Installation Guide

### Quick start

**Omarchy:**

```bash
git clone https://github.com/Malik-Hacini/dotfiles ~/dotfiles
cd ~/dotfiles
git switch omarchy
./install-omarchy.sh
```

The Omarchy installer adds only the missing personal packages, safely backs up conflicting user files, applies `packages/stow_list.omarchy.txt`, and refreshes the active theme. It intentionally does not install or stow the legacy i3/X11 desktop packages.

See [OMARCHY.md](OMARCHY.md) for profile ownership, keybinding translations, and compatibility notes.

**Ubuntu/Debian with i3:**
```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Malik-Hacini/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

**Standalone Arch Linux with i3:**

```bash
sudo pacman -Syu --needed git 
git clone https://github.com/Malik-Hacini/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

> [!WARNING]
> Do not run either installer with `sudo` or as `root`.
> The installer performs user-scoped setup under `$HOME` and runs commands that must execute in the real user session.
> Run it as your normal user account with sudo access; the script will call `sudo` itself only for the system-level steps that need it.

> [!NOTE]
> The installer force-restows packages by default. If an existing file in `$HOME` conflicts with a tracked dotfile, it is moved to `~/dotfiles-stow-backup-...` and the repo version is stowed in its place.

Legacy installer log: `<repo>/install.log` (for the default clone path, `~/dotfiles/install.log`)

### First login checks

1. Open the keybindings cheatsheet with `Super + /`.
2. Open Neovim and run `:checkhealth`.
3. Launch and restart Zen once. A user path service copies the dynamic CSS into the new profile automatically.
4. If you use Julia in Neovim, bootstrap the local Julia LSP environment once:

```bash
# Stable Julia LSP bootstrap for the dedicated Neovim LanguageServer environment.
julia --startup-file=no --history-file=no --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add("LanguageServer"); Pkg.add("SymbolServer"); Pkg.add("StaticLint"); Pkg.instantiate()'

# Julia 1.12+ fallback: use newer upstream branches if released packages fail.
julia --startup-file=no --history-file=no --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add(PackageSpec(name="LanguageServer", rev="main")); Pkg.add(PackageSpec(name="SymbolServer", rev="master")); Pkg.add(PackageSpec(name="StaticLint", rev="master")); Pkg.instantiate(); Pkg.precompile()'
```

## What The Installers Provision

### Omarchy profile

- Missing Arch/AUR packages from `packages/omarchy.arch.txt` and `packages/omarchy.aur.arch.txt`
- Personal application key aliases layered over Omarchy's complete default Hyprland keymap
- Dynamic Omarchy colors for Neovim, Foot, Kitty, btop, LazyGit, tmux, Yazi, Zathura, Qutebrowser, Zen, Starship, and Fastfetch
- TPM, tmux-resurrect, tmux-continuum, user services, portal routing, and MIME handlers
- Zen profile CSS synchronization after the browser creates its first profile

### Legacy `install.sh` profile

### Packages
Defined in distro-specific package lists:

- Debian/Ubuntu: `packages/common.txt` and `packages/desktop.txt`
- Arch-based: `packages/common.arch.txt` and `packages/desktop.arch.txt`
- Arch AUR: `packages/common.aur.arch.txt` and `packages/desktop.aur.arch.txt`

Package managers installs are preferred whenever they ship the latest version. This leads to a lot of external PPAs, official binaries and source installs on Ubuntu. Use Arch if you can.

### Arch login manager theme
- `tagarchy` SDDM theme installed to `/usr/share/sddm/themes/tagarchy`
- theme selection config installed to `/etc/sddm.conf.d/zz-tagarchy-theme.conf` 
- custom X11 display setup script installed to `/usr/local/share/sddm/scripts/tagarchy-xsetup` to seed `Xcursor.theme` and `Xcursor.size` before the Qt6 greeter starts
- blurred background generated from `~/Pictures/Wallpapers/catppuccin_gyro.jpg`

### Python Tools (via pipx)
Installed in isolated environments to avoid breaking system Python:
- `ipython`, `jupytext`, `black`, `isort`, `pylint`

### Source-built CLI tools
- TUXEDO Tailor CLI (`tailor`) from [`AaronErhardt/tuxedo-rs`](https://github.com/AaronErhardt/tuxedo-rs)

### Default `xdg-open` handlers
- `zathura-tabbed.desktop` for PDF and common PDF-like MIME aliases
- `sxiv-tabbed.desktop` for common image MIME types
- `zen.desktop` for HTML/XML documents and `http`/`https`/`ftp` URL schemes
- `yazi.desktop` for directory opens (`inode/directory`)

### Fonts
All fonts are installed under `/usr/local/share/fonts/`
- `JetBrainsMono Nerd Font`
- `RobotoMono Nerd Font`
- `NerdFontsSymbolsOnly`
- `Font Awesome`

### GTK / GNOME  apps appearance
All GNOME and GTK apps are themed using Catppuccin (Mocha flavor). This includes GTK2/GTK3/GTK4/libadwaita apps and a workaround for sandboxed apps (flatpaks)

### Zen Browser CSS
- source of truth: `zen/.config/zen/chrome/`
- stowed to `~/.config/zen/chrome/`
- Omarchy generates palette and logo assets from the active theme
- `zen-dotfiles-profile.path` copies real files into new native or Flatpak Zen profiles automatically

## Stow 
Each installer stows only the packages in its profile list.

Use `bash scripts/.local/bin/force-stow-dotfiles` to re-apply the active profile after another tool recreates config files under `$HOME`. It automatically selects `packages/stow_list.omarchy.txt` when Omarchy is installed.

## Legacy Installer Flags

These flags apply only to `install.sh`. `install-omarchy.sh` deliberately performs the complete Omarchy profile setup and rejects optional arguments.

| Flag | Meaning |
|---|---|
| `--headless`, `--no-gui` | Skip desktop/GUI packages (i3, polybar, fonts, wallpapers, Zen browser). |
| `--skip-packages` | Skip system package installation (`apt`/`pacman`). |
| `--skip-tools` | Skip external tool installation (binaries like `starship`, `yazi`, `typst`, etc.). |
| `--skip-fonts` | Skip Nerd Fonts installation. |
| `--skip-ppas` | Skip adding Ubuntu PPAs and Debian/Ubuntu external apt repos. |
| `--stow-only` | Only run stow (skip all installations). |

## Machine-Local Overrides

Keep personal and machine-specific values in local files, not in the tracked files of this repo:

- Git identity/settings: `~/.gitconfig.local` 
- Fish local env vars/secrets: `~/.config/fish/local.fish`
- Omarchy monitor configuration: `~/.config/hypr/monitors.lua`
- Legacy i3 monitor/power configuration: `~/.config/i3/local.conf`

These files are automatically included in the main configs if present.
