# Plugin Layout

Plugin specs are organized by domain and loaded through lazy.nvim category imports.

## Categories

- `editor/`: core editing workflow
  - `which-key.lua`, `formatting.lua`, `linting.lua`, `telescope.lua`, `toggleterm.lua`, `treesitter.lua`
- `lsp/`: LSP/completion and external tool management
  - `lspconfig.lua`, `mason.lua`, `none-ls.lua`, `nvim-cmp.lua`, `vimtex-cmp.lua`
- `tools/`: utility and integration plugins
  - git (`gitsigns.lua`, `lazygit.lua`), AI (`opencode.lua`, `copilot.lua`), file tools (`yazi.lua`), editor helpers (`mini.lua`, `surround.lua`, `todo-comments.lua`, `yanky.lua`, `autolist/`, `snacks/`, `firenvim.lua`)
- `text/`: writing-focused plugins
  - `vimtex.lua`, `markdown-preview.lua`, `jupyter/`
- `ui/`: visual shell around editing
  - `colorscheme.lua`, `lualine.lua`, `bufferline.lua`, `nvim-tree.lua`, `nvim-web-devicons.lua`, `sessions.lua`
- `typst/`: Typst support
  - `typst-preview.lua`, `typst-vim.lua`, `luasnip.lua`

## Loading Model

- Each category has an `init.lua` aggregator.
- `lua/neotex/bootstrap.lua` imports category modules into `lazy.setup(...)`.
- `lua/neotex/plugins/init.lua` remains a compatibility shim returning `{}`.

## Notes

- `lazygit.nvim` is the active LazyGit integration.
- Snacks' `lazygit` module is intentionally disabled to avoid overlap.
- `nvim-tree` and `yazi` are both kept intentionally for different file-navigation workflows.
