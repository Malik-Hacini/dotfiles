# NeoVim Plugin Organization

This directory contains plugin specs managed by `lazy.nvim`.

## Current Structure

Plugins are grouped by responsibility:

- `editor/`: editing workflow and core UX
  - `which-key.lua`, `formatting.lua`, `linting.lua`, `telescope.lua`, `toggleterm.lua`, `treesitter.lua`
- `tools/`: external tools and utility plugins
  - `gitsigns.lua`, `firenvim.lua`, `mini.lua`, `surround.lua`, `todo-comments.lua`, `yanky.lua`, `copilot.lua`, `opencode.lua`, `autolist/`, `snacks/`, `lazygit.lua`, `yazi.lua`
- `text/`: writing and text-domain plugins
  - `vimtex.lua`, `markdown-preview.lua`, `jupyter/`
- `ui/`: visual interface components
  - `colorscheme.lua`, `lualine.lua`, `bufferline.lua`, `nvim-tree.lua`, `nvim-web-devicons.lua`, `sessions.lua`
- `typst/`: Typst-specific plugins
  - `typst-preview.lua`, `typst-vim.lua`, `luasnip.lua`
- `lsp/`: language server and completion stack
  - `lspconfig.lua`, `mason.lua`, `none-ls.lua`, `nvim-cmp.lua`, `vimtex-cmp.lua`

## Loading Model

- Each category has an `init.lua` that safely requires module specs and returns a plugin table.
- `lua/neotex/bootstrap.lua` wires categories into `lazy.setup(...)` using category imports.
- `lua/neotex/plugins/init.lua` intentionally returns `{}` as a compatibility shim.

## Adding a Plugin

1. Place a plugin spec file in the correct category.
2. Export a valid lazy.nvim spec table from that file.
3. Register it via that category's `init.lua`.
4. Restart Neovim and verify with `:Lazy` and `:checkhealth`.
