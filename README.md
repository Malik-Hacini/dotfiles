# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for an Ubuntu + i3 (X11) workflow.
Theme: **Catppuccin Mocha**.

Main stack:

- i3 + polybar + picom + rofi + dunst
- Alacritty + Fish + Starship
- Neovim (NeoTex) + Yazi + Zathura + Qutebrowser

## Fresh Install (Recommended)

### 1) Pre-reqs

The bootstrap script is Ubuntu-focused and uses `apt` + PPAs.
On non-Ubuntu Debian derivatives, run with `--skip-packages` and install equivalents manually.

```bash
sudo apt update
sudo apt install -y git curl software-properties-common
```

### 2) Clone and run installer

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### 3) First boot steps

1. Log out and back in (fish is set as default shell).
2. Open Neovim and run:
   - `:Lazy sync`
   - `:Mason`
   - `:checkhealth`

Installer log is written to `~/dotfiles/install.log`.

## Installer Flags

```bash
./install.sh --skip-tools     # Skip fzf/starship/zoxide/yazi/lazygit/opencode/python/tabbed
```

## What `install.sh` Installs

### Repositories added

- `ppa:neovim-ppa/unstable`
- `ppa:fish-shell/release-4`
- `ppa:aslatter/ppa`
- NodeSource LTS repo (if `node` is missing)

### APT packages

Everything in `packages.txt`, including:

- Core: `git`, `stow`, `curl`, `wget`, `unzip`, `build-essential`, `cmake`, `pkg-config`
- Desktop: `i3-wm`, `i3lock`, `i3status`, `polybar`, `picom`, `rofi`, `dunst`, `flameshot`, `xdotool`, `x11-xserver-utils`, `dex`, `xss-lock`, `network-manager-gnome`, `pulseaudio-utils`
- CLI: `htop`, `neofetch`, `ripgrep`, `fd-find`, `bat`, `feh`, `jq`
- Docs/academic: `zathura`, `zathura-pdf-poppler`, `texlive-full`, `latexmk`
- Media/viewer: `sxiv`, `vlc`, `xwininfo`
- Python base: `python3`, `python3-pip`, `python3-venv`
- Build deps for `tabbed`: `libx11-dev`, `libxft-dev`

Also installed explicitly by script:

- `neovim`, `fish`, `alacritty`, `nodejs`, `qutebrowser`

### Non-APT installs

- `fzf` (git clone to `~/.fzf`)
- `starship` (official installer)
- `zoxide` (official installer)
- `yazi` + `ya` (GitHub release binary)
- `lazygit` (GitHub release binary)
- `opencode` (official installer from opencode.ai)
- Yazi plugin sync via `ya pack -i`
- Python user tools: `ipython`, `jupytext`, `black`, `isort`, `pylint`
- `tabbed` built from source to `~/.local/bin/tabbed`
- Fonts: `JetBrainsMono`, `RobotoMono`, `NerdFontsSymbolsOnly`, `Font Awesome`

## Stow Packages Applied by Installer

`install.sh` stows these packages automatically:

| Package | Target |
|---|---|
| `bash` | `~/.bashrc`, `~/.profile`, `~/.fzf.bash` |
| `fish` | `~/.config/fish/` |
| `starship` | `~/.config/starship.toml` |
| `git` | `~/.gitconfig` |
| `i3` | `~/.config/i3/config` |
| `polybar` | `~/.config/polybar/` |
| `picom` | `~/.config/picom/picom.conf` |
| `rofi` | `~/.config/rofi/` |
| `dunst` | `~/.config/dunst/dunstrc` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `nvim` | `~/.config/nvim/` |
| `yazi` | `~/.config/yazi/` |
| `zathura` | `~/.config/zathura/` |
| `lazygit` | `~/.config/lazygit/config.yml` |
| `fontconfig` | `~/.config/fontconfig/fonts.conf` |
| `neofetch` | `~/.config/neofetch/config.conf` |
| `htop` | `~/.config/htop/htoprc` |
| `qutebrowser` | `~/.config/qutebrowser/` |
| `xdg-desktop-portal` | `~/.config/xdg-desktop-portal/portals.conf` |
| `xdg-desktop-portal-termfilechooser` | `~/.config/xdg-desktop-portal-termfilechooser/` |
| `latex` | `~/texmf/` (custom `.bst` files) |
| `scripts` | `~/.local/bin/rofi-power`, `~/.local/bin/zathura-tabbed`, `~/.local/bin/sxiv-tabbed` |
| `wallpapers` | `~/Pictures/Wallpapers/` |
| `opencode` | `~/.config/opencode/opencode.json` |

## Manual Setup (Important)

These items are intentionally not fully automated.

### 1) xdg-desktop-portal-termfilechooser backend (for Yazi file picker)

The config is stowed, but the backend binary must be installed manually.

```bash
sudo apt install -y meson ninja-build xdg-desktop-portal xdg-desktop-portal-gtk

git clone https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser.git /tmp/xdptf
cd /tmp/xdptf
meson setup build
ninja -C build
sudo ninja -C build install
```

Then relogin, or run:

```bash
systemctl --user import-environment
systemctl --user restart xdg-desktop-portal-termfilechooser.service
```

Architecture/debug notes are in `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/agents.md`.

### 2) Machine-specific monitor config

Create `~/.config/i3/local.conf` for machine-local `xrandr` and similar overrides.

```bash
cat > ~/.config/i3/local.conf << 'EOF'
# Example
exec --no-startup-id xrandr --output eDP-1 --off --output HDMI-1 --auto
EOF
```

### 3) Polybar hardware names

`polybar/.config/polybar/config.ini` currently uses:

- Wireless interface: `wlo1`
- Battery: `BAT0`
- AC adapter: `ADP1`

If your machine uses different names, update them.

### 4) Tabbed wrappers extra deps

`zathura-tabbed` and `sxiv-tabbed` rely on additional tools not in `packages.txt`:

```bash
sudo apt install -y x11-utils
```

Note: `jq` and `xdotool` are already in `packages.txt` and installed automatically.

### 5) Custom `tabbed` source (optional)

If you want a patched/themed `tabbed` build, place your source tree at:

- `~/dotfiles/tabbed-src/`

`install.sh` will build that local source instead of cloning vanilla upstream.

### 6) Zen Browser (optional)

`fish` and `bash` expose `zen` alias only if this binary exists:

- `~/.local/opt/zen/zen`

### 7) CUDA (optional)

Shell configs auto-detect `/usr/local/cuda-12.8` or `/usr/local/cuda` and update `PATH` / `LD_LIBRARY_PATH` when present.

### 8) Firecrawl API key for OpenCode MCP (optional)

OpenCode is installed automatically by `install.sh` and its config is stowed from `opencode/`. If you use the Firecrawl MCP server, configure the API key:

```bash
mkdir -p ~/.config/opencode
printf '%s' 'fc-your-key-here' > ~/.config/opencode/firecrawl_api_key
chmod 600 ~/.config/opencode/firecrawl_api_key
```

This secret file is ignored by git and referenced by `opencode.json`.

### 9) Zotero bibliography (optional)

Neovim bibliography tooling expects:

- `~/texmf/bibtex/bib/Zotero.bib`

## Neovim External Tooling Notes

On first run, Mason auto-installs configured LSP/formatter/linter tools (pyright, texlab, tinymist, lua-language-server, stylua, prettier, shellcheck, markdownlint, etc.).

System tools expected by the config include:

- `node/npm` (Markdown preview, JS-based tooling)
- `python3/pip` (`ipython`, notebook flow)
- `git`, `make`, C toolchain
- `lazygit`, `yazi`, `zathura`, `latexmk`, `qutebrowser`
- `pandoc` (optional, for Neovim document export keymaps)

## Day-2 Operations

```bash
cd ~/dotfiles
stow -D <package>   # remove symlinks for one package
stow -R <package>   # restow one package
```

To add a new stow package:

```bash
mkdir -p ~/dotfiles/newpkg/.config/newpkg
cp ~/.config/newpkg/config.toml ~/dotfiles/newpkg/.config/newpkg/
cd ~/dotfiles
stow newpkg
```

The folder structure inside each package must match the path relative to `$HOME`.
