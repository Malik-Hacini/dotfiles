# NeoTex Neovim Configuration

NeoTex is a Lua-first Neovim configuration focused on:

- academic writing (LaTeX, Markdown, Typst)
- Python and notebook workflows
- modern editor UX (LSP, linting, formatting, Telescope, sessions)
- practical AI assistance with OpenCode and Copilot

This file is intentionally concise and points to focused docs in this repo.

## Current Feature Set

- LaTeX: VimTeX workflow (build/view/toc/context/citations/templates)
- Markdown: autolist integration, checkbox helpers, preview support
- Typst: tinymist LSP + typst preview tooling
- Jupyter: jupytext + notebook-navigator + iron.nvim integration
- LSP: pyright, texlab, tinymist, lua-language-server
- Formatting: conform.nvim (`<leader>mp`) with per-filetype formatters
- Linting: nvim-lint (`<leader>l` / `<leader>lL`) with executable-aware setup
- AI: OpenCode actions plus Copilot control from `<leader>h`

## Quick Start

1. Open Neovim in this config.
2. Run `:Lazy sync`.
3. Run `:Mason` to inspect tool installs (auto-install is configured).
4. Run `:checkhealth`.

## Daily Commands

- Plugin management:
  - `:Lazy`
  - `<leader>rr` reload config (`:ReloadConfig`)
  - `<leader>rk` wipe lazy plugins + lockfile (full reinstall path)
- Formatting and linting:
  - `<leader>mp` format buffer/selection
  - `:FormatToggle` / `:FormatToggle buffer`
  - `<leader>l` or `<leader>lL` lint now
  - `:LintToggle` / `:LintToggle buffer`
- LSP lifecycle:
  - `<leader>lt` start
  - `<leader>lk` stop
  - `<leader>ls` restart

## AI Workflow

AI mappings live under `<leader>h`.

- OpenCode:
  - `<leader>ha` ask about current context
  - `<leader>hc` action picker
  - `<leader>ht` toggle OpenCode terminal
- Copilot:
  - `<leader>he` enable
  - `<leader>hd` disable
  - `<leader>hs` status
  - `<leader>hp` panel
  - `<leader>hn` / `<leader>hb` next/prev suggestion
  - `<leader>hl` / `<leader>hw` accept line/word
  - `<leader>hx` dismiss suggestion

Notes:

- Copilot is lazy-loaded and not started automatically on launch.
- OpenCode is the primary in-editor chat/action workflow.

## Jupyter Workflow

Notebook operations are grouped under `<leader>j`.

- Core:
  - `<leader>je` run cell
  - `<leader>jn` run and move next
  - `<leader>ja` run all cells
  - `<leader>jj` / `<leader>jk` next/previous cell
- REPL:
  - `<leader>ji` start IPython REPL
  - `<leader>jl` send line
  - `<leader>jv` send visual selection
  - `<leader>jf` send file

## Tooling Model

The config prepends Mason binaries to Neovim PATH at startup, so editor tools are resolved inside Neovim even if your shell PATH differs.

### LSP Servers

- `pyright` (Python)
- `texlab` (LaTeX)
- `tinymist` (Typst)
- `lua_ls` (Lua)

### Formatters

- Lua: `stylua`
- Python: `isort`, `black`
- JS/TS/CSS/HTML/JSON/YAML/Markdown: `prettier`
- C/C++: `clang-format`
- Shell: `shfmt`
- TeX: `latexindent`

### Linters (dynamic by executable)

- Python: `pylint`
- Lua: `luacheck` or fallback `selene`
- JS/TS: `eslint` or fallback `eslint_d`
- CSS: `stylelint`
- HTML: `tidy` or fallback `htmlhint`
- JSON: `jsonlint`
- YAML: `yamllint`
- Shell: `shellcheck`
- Markdown: `markdownlint`
- C/C++: `cppcheck` or fallback `cpplint`

## Directory Map

- `init.lua`: entry point
- `lua/neotex/config/`: options, keymaps, autocmds
- `lua/neotex/plugins/`: lazy.nvim plugin specs by domain
- `lua/neotex/util/`: reusable helper modules and user commands
- `after/ftplugin/`, `after/ftdetect/`: filetype-specific behavior
- `templates/`, `snippets/`, `LuaSnip/`: writing support assets

## Performance and Health

- `:AnalyzeStartup`
- `:ProfilePlugins`
- `:OptimizationReport`
- `:SuggestLazyLoading`
- `:checkhealth`

## Related Docs

- `AGENTS.md`: machine-readable project context and conventions
- `OPTIMIZATION.md`: optimization strategy and workflow
- `lua/neotex/plugins/README.md`: plugin category layout
- `lua/neotex/config/README.md`: core config module notes
- `lua/neotex/util/README.md`: utility modules and user commands
