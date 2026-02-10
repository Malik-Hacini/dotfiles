# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), themed with **Catppuccin Mocha**.

i3 + polybar + picom + rofi + dunst | Alacritty + Fish + Starship | Neovim (NeoTex)

## Quick Start

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
sudo apt install stow
./install.sh
```

After installation, log out and back in for the fish shell change to take effect, then open Neovim and run `:Lazy sync`.

## What Gets Installed

### Via PPAs (latest versions)
| Package | PPA | Why |
|---------|-----|-----|
| Neovim | `ppa:neovim-ppa/unstable` | Ubuntu apt ships 0.7.x, config needs 0.10+ |
| Fish | `ppa:fish-shell/release-4` | Ubuntu apt ships old 3.x |
| Alacritty | `ppa:aslatter/ppa` | Not in Ubuntu repos |
| Node.js | NodeSource LTS | Needed by nvim plugins (markdown-preview, Mason LSPs) |

### Via apt (from packages.txt)
i3-wm, polybar, picom, rofi, dunst, flameshot, zathura, sxiv, texlive-full, htop, neofetch, python3, qutebrowser, vlc, and build dependencies.

### Via binary/script installers
| Tool | Method |
|------|--------|
| fzf | `git clone` to `~/.fzf` (apt version is 0.29, current is 0.67+) |
| Starship | Official install script |
| Zoxide | Official install script |
| Yazi | GitHub release binary |
| Lazygit | GitHub release binary |

### Built from source
| Tool | Purpose |
|------|---------|
| suckless tabbed | Tab container for zathura and sxiv (zathura-tabbed, sxiv-tabbed scripts) |

### Python tools (pip --user)
ipython, jupytext, black, isort, pylint — all used by Neovim plugins.

### Fonts
JetBrainsMono Nerd Font, RobotoMono Nerd Font, NerdFontsSymbolsOnly, Font Awesome.

## Stow Packages

| Package | What it manages |
|---------|----------------|
| `bash` | `.bashrc`, `.profile`, `.fzf.bash` |
| `fish` | `~/.config/fish/` (config.fish, functions) |
| `starship` | `~/.config/starship.toml` |
| `git` | `.gitconfig` |
| `i3` | `~/.config/i3/config` |
| `polybar` | `~/.config/polybar/` (config, launch script, modules) |
| `picom` | `~/.config/picom/picom.conf` |
| `rofi` | `~/.config/rofi/` (config.rasi, catppuccin theme, power menu) |
| `dunst` | `~/.config/dunst/dunstrc` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `nvim` | `~/.config/nvim/` (NeoTex config — LaTeX/Typst/Python) |
| `yazi` | `~/.config/yazi/` (config, plugins, catppuccin flavor) |
| `zathura` | `~/.config/zathura/` (zathurarc, catppuccin theme) |
| `lazygit` | `~/.config/lazygit/config.yml` |
| `qutebrowser` | `~/.config/qutebrowser/` |
| `fontconfig` | `~/.config/fontconfig/` |
| `neofetch` | `~/.config/neofetch/config.conf` |
| `htop` | `~/.config/htop/htoprc` |
| `latex` | `~/texmf/` (custom .bst files) |
| `scripts` | `~/.local/bin/rofi-power`, `~/.local/bin/zathura-tabbed`, `~/.local/bin/sxiv-tabbed` |

## Install Script Options

```
./install.sh                  # Full install
./install.sh --stow-only      # Only create symlinks (no package installs)
./install.sh --skip-packages  # Skip apt/PPA installs
./install.sh --skip-tools     # Skip binary tool installs (fzf, starship, etc.)
./install.sh --skip-fonts     # Skip font installs
```

## Manual Setup Required

These items cannot be automated by the install script and must be set up manually:

### Zen Browser

The fish and bash configs alias `zen` to `~/.local/opt/zen/zen`. The alias is conditional — it only activates if the binary exists. To install:

1. Download the AppImage from [zen-browser.app](https://zen-browser.app/)
2. Extract to `~/.local/opt/zen/`
3. Ensure `~/.local/opt/zen/zen` is executable

### CUDA Toolkit

Both fish and bash configs conditionally add CUDA to `PATH` and `LD_LIBRARY_PATH` if `/usr/local/cuda-12.8` (or `/usr/local/cuda`) exists. If you need CUDA:

1. Follow [NVIDIA's installation guide](https://developer.nvidia.com/cuda-downloads) for your GPU
2. The configs auto-detect the installation path

### Monitor Configuration

The i3 config includes `~/.config/i3/local.conf` for machine-specific commands (xrandr, xmodmap, etc.). This file is **not tracked by git** — create it on each machine:

```bash
cat > ~/.config/i3/local.conf << 'EOF'
# Machine-specific i3 config
exec --no-startup-id xrandr --output eDP-1 --off --output HDMI-1 --auto
EOF
```

Run `xrandr --listmonitors` to find your output names. i3 silently ignores the `include` if the file doesn't exist, so this is safe to skip on machines where the default display is fine.

### OpenCode

The fish config conditionally adds `~/.opencode/bin` to PATH if it exists. Install from [opencode.ai](https://opencode.ai) if desired.

### Zotero Bibliography

The Neovim config (telescope-bibtex) expects `~/texmf/bibtex/bib/Zotero.bib`. If you use Zotero for reference management, configure Better BibTeX to auto-export to this path.

### Suckless tabbed (Catppuccin theme)

The install script builds a vanilla `tabbed` from suckless.org. If you want the Catppuccin-themed version, you can place a patched `tabbed` source tree at `~/dotfiles/tabbed-src/` before running install — the script will detect and use it instead of cloning vanilla upstream. Otherwise you can rebuild with your preferred patches after install.

## Neovim Plugin Dependencies

The NeoTex config uses lazy.nvim and expects these external tools (most are installed by the script):

| Tool | Purpose | Installed by |
|------|---------|-------------|
| node/npm | markdown-preview, Mason LSPs | install.sh (NodeSource) |
| python3/pip | pyright, jupytext, ipython, formatters | install.sh (apt + pip) |
| git | Plugin manager, gitsigns, lazygit | install.sh (apt) |
| make + cc | telescope-fzf-native | install.sh (build-essential) |
| lazygit | Git TUI within nvim | install.sh (binary) |
| yazi | File manager within nvim | install.sh (binary) |
| fish | toggleterm default shell | install.sh (PPA) |
| zathura | vimtex PDF viewer | install.sh (apt) |
| latexmk | vimtex build system | install.sh (apt) |
| qutebrowser | typst-preview browser | install.sh (apt) |
| stylua | Lua formatter | Mason auto-install |
| prettier | Web formatter | Mason auto-install |

Mason will auto-install LSP servers (pyright, texlab, tinymist, lua_ls) and linting/formatting tools on first use.

## Uninstalling a Package

```bash
cd ~/dotfiles
stow -D <package>   # Remove symlinks for a package
```

## Adding a New Package

```bash
mkdir -p ~/dotfiles/newpkg/.config/newpkg
cp ~/.config/newpkg/config.toml ~/dotfiles/newpkg/.config/newpkg/
cd ~/dotfiles && stow newpkg
```

The directory structure inside each package must mirror the path relative to `$HOME`.
