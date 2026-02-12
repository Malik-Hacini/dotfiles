# AGENTS.md - NeoTex NeoVim Configuration

Author: Benjamin Brast-McKie
Config name: NeoTex

## Overview

This is a NeoVim configuration focused on academic writing (LaTeX, Typst, Markdown),
Python development, Jupyter notebooks, and Lua plugin development. It runs on NixOS and
uses lazy.nvim for plugin management. AI workflows are built around OpenCode + Copilot
plus Lectic utilities for writing workflows.

## Build / Lint / Test Commands

There is no traditional build system. This is a NeoVim Lua configuration managed by lazy.nvim.

### Plugin Management (lazy.nvim)
- `:Lazy` - Open lazy.nvim UI (install, update, clean, profile plugins)
- `:Lazy sync` - Install missing plugins and update existing ones
- `:Lazy update` - Update all plugins
- `<leader>rk` - Wipe all plugins and lazy-lock.json (full reinstall)
- `<leader>rc` - Clear plugin cache (`~/.cache/nvim`)
- `<leader>rr` - Reload Neovim configuration (`:ReloadConfig`)

### Linting
- `<leader>l` - Lint current file (nvim-lint `try_lint()`)
- `<leader>lL` - Lint current file (same, under LSP group)
- Auto-lints on `BufWritePost`/`BufEnter` for: python, lua, javascript, typescript
- `:LintToggle` / `:LintToggle buffer` - Toggle auto-linting globally or per-buffer
- Linters: eslint/eslint_d (JS/TS), pylint (Python), luacheck/selene (Lua),
  shellcheck (sh), markdownlint, cppcheck/cpplint (C/C++), stylelint (CSS),
  tidy/htmlhint (HTML), jsonlint, yamllint
- Only linters found on `$PATH` are activated (checked via `vim.fn.executable`)

### Formatting
- `<leader>mp` - Format buffer or selection (conform.nvim, async with LSP fallback)
- `:FormatToggle` / `:FormatToggle buffer` - Toggle format-on-save
- Format-on-save is disabled by default; use `<leader>mp` manually
- Formatters by filetype:
  - Lua: `stylua` (2-space indent, double quotes)
  - Python: `isort` (profile=black) then `black` (88 char line limit)
  - JS/TS/CSS/HTML/JSON/YAML/Markdown: `prettier`
  - C/C++: `clang_format`
  - Shell: `shfmt` (2-space indent)
  - LaTeX: `latexindent`
  - All files: `trim_whitespace`, `trim_newlines`

### LSP
- Servers: `pyright` (Python), `texlab` (LaTeX), `tinymist` (Typst), `lua_ls` (Lua)
- Uses the modern `vim.lsp.config()` / `vim.lsp.enable()` API (not deprecated lspconfig setup)
- Mason manages LSP server installation
- `<leader>ls` - Restart LSP, `<leader>lk` - Stop LSP, `<leader>lt` - Start LSP

### Diagnostics
- `<leader>ll` - Line diagnostics (float), `<leader>lb` - Buffer diagnostics (Telescope)
- `<leader>ln` / `<leader>lp` - Next/previous diagnostic
- Config: virtual_text=true, signs=true, underline=true, update_in_insert=false

### Testing
- No test framework is configured for this NeoVim config itself.
- For Python files edited in this NeoVim: run via `<leader>ap` (TermExec python3)
- For Jupyter: `<leader>je` execute cell, `<leader>jn` execute and next, `<leader>ja` run all

### Performance Profiling
- `:AnalyzeStartup` - Profile startup time (runs headless Neovim subprocess)
- `:ProfilePlugins` - Analyze plugin load times
- `:OptimizationReport` - Generate full optimization report
- `:SuggestLazyLoading` - Suggest lazy-loading improvements

## Directory Structure

```
init.lua                          Entry point: sets leader, loads config + bootstrap
lua/neotex/
  bootstrap.lua                   Installs lazy.nvim, loads plugin specs, inits utils
  config/
    init.lua                      Loads options -> keymaps -> autocmds in sequence
    options.lua                   Core vim.opt settings
    keymaps.lua                   Global and buffer-specific keymaps
    autocmds.lua                  Autocommands (terminal, markdown, special buffers)
  plugins/
    editor/                       Formatting, linting, telescope, toggleterm, treesitter, which-key
    lsp/                          lspconfig, mason, none-ls, nvim-cmp, vimtex-cmp
    tools/                        gitsigns, firenvim, lazygit, mini, surround, todo-comments,
                                  yanky, yazi, snacks, autolist, opencode, copilot
    text/                         vimtex, markdown-preview, jupyter (jupytext, iron, notebook-navigator)
    ui/                           catppuccin theme, bufferline, lualine, nvim-tree, sessions
    typst/                        typst-preview, typst.vim, typst-specific LuaSnip config
  util/
    init.lua                      Utility loader: safe_require, submodule aggregation
    buffer.lua                    Buffer navigation (sorted by modified time)
    fold.lua                      Fold management with persistence and markdown fold expr
    url.lua                       URL detection and opening (gx, Ctrl+Click)
    diagnostics.lua               LSP diagnostic helpers, Jupyter cell utilities
    misc.lua                      OS detection, safe_execute, trim_whitespace, toggle_line_numbers
    optimize.lua                  Startup/plugin profiling suite
    lectic_extras.lua             Lectic AI chat integration helpers
after/ftplugin/                   Filetype overrides: python.lua, tex.lua, markdown.lua
after/ftdetect/                   ipynb.lua (Jupyter notebook detection)
LuaSnip/                          Lua-based snippets: all.lua, lua.lua, typst.lua
snippets/                         Snipmate-format: tex.snippets, markdown.snippets, python.snippets
templates/                        LaTeX document templates
  scripts/                          Shell/Lua maintenance scripts (plugin/tool checks)
```

## Bootstrap Chain

1. `init.lua` sets `vim.g.mapleader = " "`, then `pcall(require, "neotex.config")` and `pcall(require, "neotex.bootstrap")`
2. `neotex.config.init` calls `setup()` on options, keymaps, autocmds in order
3. `neotex.bootstrap.init()` runs a sequential step pipeline:
   cleanup_tmp_dirs -> ensure_lazy -> validate_lockfile -> setup_lazy -> setup_utils -> setup_jupyter_styling
4. `setup_lazy()` calls `require("lazy").setup(...)` with imports for each plugin category
5. `setup_utils()` loads all `neotex.util.*` submodules and calls their `setup()` functions

## Code Style Guidelines

### Indentation and Formatting
- **2 spaces** for indentation everywhere (no tabs); `expandtab = true`
- **~100 character** line length (soft limit, no enforced colorcolumn in most buffers)
- Python: 88-char line limit (black standard), colorcolumn set in `after/ftplugin/python.lua`

### Module Pattern
Every Lua module follows the same structure:
```lua
local M = {}

function M.setup()
  -- initialization logic
  return true
end

return M
```
Setup functions return `true` on success for pipeline checking.

### Naming Conventions
- **Variables and functions**: `snake_case` (e.g., `load_folding_state`, `setup_url_mappings`)
- **Modules**: `snake_case` filenames (e.g., `lectic_extras.lua`, `list_operations.lua`)
- **Global functions**: `PascalCase` prefixed with `_G.` (e.g., `_G.LoadFoldingState`, `_G.IncrementCheckbox`)
- **Private functions**: prefix with underscore (`M._load_submodules`)
- **Constants/flags**: `_G._prevent_cmp_menu`, `_G._last_tab_was_indent`

### Imports and Dependencies
- Place `require` calls at the top of each file or function scope
- Lazy-load heavy modules: `require("module")` inside functions rather than at file top
- Use `pcall(require, "module")` for any optional or potentially missing dependency
- Plugin init files use `safe_require()` pattern returning `{}` on failure
- Order: standard library -> vim API -> local modules -> plugin modules

### Error Handling
- **Always** use `pcall` for operations that might fail (requires, I/O, API calls)
- Pattern: `local ok, result = pcall(require, "module")` then check `ok`
- Bootstrap uses `with_error_handling(func, msg)` wrapper for step-based init
- Notify errors with `vim.notify(msg, vim.log.levels.ERROR)`
- Provide fallbacks: global function fallbacks (`_G.Function`), minimal config fallback in init.lua

### Backward Compatibility
- Expose global aliases: `_G.FunctionName = M.function_name` for backward compat
- Modules check for both new module path and legacy `_G` functions
- Example: `neotex.util.fold` sets `_G.LoadFoldingState = M.load_folding_state`

### Plugin Specs (lazy.nvim)
- One plugin per file, returning a table (or table of tables)
- Use lazy-loading triggers: `event`, `ft`, `cmd`, `keys` whenever possible
- Group by category in subdirectories (editor/, lsp/, tools/, text/, ui/, typst/)
- Each category has an `init.lua` that aggregates specs via `safe_require`

### Keymaps
- Use `vim.keymap.set(mode, key, cmd, opts)` with `{ noremap = true, silent = true, desc = "..." }`
- Always include `desc` for which-key integration
- Buffer-local maps use `{ buffer = true }` or `vim.api.nvim_buf_set_keymap`
- Leader key is Space; all leader maps defined in which-key.lua
- Helper functions `map()` and `buf_map()` defined in keymaps.lua for consistency

### Comments
- File headers use `---` block comment style with author, description, structure notes
- Section headers use `-- SECTION NAME --` with dashes
- Document all keymaps with inline `desc` parameter
- Use `--[[ ]]` for multi-line reference documentation (e.g., keymap tables in keymaps.lua)

### Notifications
- Use `vim.notify(msg, vim.log.levels.LEVEL)` with appropriate level (INFO/WARN/ERROR)
- Minimize startup notifications (removed most "loaded successfully" messages)
- `vim.notify_level` set to `INFO` in init.lua

### Deferred Execution
- Use `vim.defer_fn(fn, ms)` for non-critical initialization (URL mappings: 200ms, Jupyter: 1500ms)
- Use `vim.schedule()` for operations that must run in the main loop
- Guard against duplicate setup with idempotency flags (e.g., `M._url_mappings_setup`)
