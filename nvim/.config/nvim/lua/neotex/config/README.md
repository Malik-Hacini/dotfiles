# Core Config Modules

This directory contains the startup configuration chain loaded by `neotex.config`.

## Files

- `init.lua`: calls `options.setup()`, `keymaps.setup()`, `autocmds.setup()` in order
- `options.lua`: base Neovim options and startup defaults
- `keymaps.lua`: global and buffer-local mappings
- `autocmds.lua`: event-driven behavior (terminal, markdown, notebook helpers, buffer behavior)

## Design Notes

- Keep startup-safe defaults in `options.lua`.
- Put reusable logic in `lua/neotex/util/*`, not directly in keymap callbacks.
- Use `pcall(require, ...)` for optional integrations.
- Avoid filetype-specific complexity in `config/*`; prefer `after/ftplugin/*`.

## Common Reload Path

```lua
require("neotex.config").setup()
```

In practice, use `:ReloadConfig` (`<leader>rr`) during interactive edits.
