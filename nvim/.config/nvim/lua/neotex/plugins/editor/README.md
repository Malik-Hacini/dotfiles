# Editor Plugins

Specs in this directory define the core editing experience.

## Included Specs

- `which-key.lua`: leader menus and grouped keybinding UX
- `formatting.lua`: conform.nvim formatter orchestration
- `linting.lua`: nvim-lint setup with executable-aware fallback logic
- `telescope.lua`: fuzzy search/navigation pickers
- `toggleterm.lua`: terminal integration and TermExec workflow
- `treesitter.lua`: syntax/tree support and related modules

## Scope Rule

If a plugin is primarily an integration or utility (AI, git wrappers, yank history, file manager wrappers), place it under `tools/` instead of `editor/`.
