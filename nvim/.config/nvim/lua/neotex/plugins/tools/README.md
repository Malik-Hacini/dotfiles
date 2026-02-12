# Tool Plugins

This directory hosts integrations and utility plugins that extend core editing.

## Major Areas

- Git: `gitsigns.lua`, `lazygit.lua`
- AI: `opencode.lua`, `copilot.lua`
- File navigation helpers: `yazi.lua`
- Text utilities: `mini.lua`, `surround.lua`, `todo-comments.lua`, `yanky.lua`, `autolist/`
- UI utility suite: `snacks/`
- Browser embedding: `firenvim.lua`

## Notes

- LazyGit integration is handled by `lazygit.nvim`.
- Snacks is used for dashboard/notifier/statuscolumn/input/terminal helpers, but not for LazyGit.
- Keep tool specs small and composable; avoid putting large editor-flow logic here.
