# UI Plugins

This directory contains interface-layer plugins.

## Included Specs

- `colorscheme.lua`: Catppuccin theme setup
- `lualine.lua`: statusline
- `bufferline.lua`: buffer/tab line behavior
- `nvim-tree.lua`: file explorer
- `nvim-web-devicons.lua`: icon provider
- `sessions.lua`: session persistence and restore flow

UI plugins should avoid owning core editor logic; keep behavior-oriented workflows in `editor/` or `tools/`.
