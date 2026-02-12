# TODO

Active maintenance backlog for NeoTex.

## High Priority

- [ ] Keep `README.md` and `which-key.lua` mapping reference synchronized.
- [ ] Add a lightweight docs check script to flag removed plugin names in markdown docs.
- [ ] Review and prune stale comments in heavily edited plugin files.

## Medium Priority

- [ ] Add a short troubleshooting doc for common LSP/formatter/linter failures.
- [ ] Improve onboarding docs for first-run Mason installs and expected behavior.
- [ ] Add a minimal "safe customizations" guide (where to edit keymaps/options/plugins).

## Low Priority

- [ ] Decide whether to keep both `nvim-tree` and `yazi` long term.
- [ ] Revisit optional filetype-specific docs for Typst and Jupyter workflows.

## Recently Completed

- [x] Removed Avante/MCPHub references from active configuration.
- [x] Rewired AI menu to OpenCode + Copilot.
- [x] Disabled Copilot startup notifications by lazy-loading Copilot.
- [x] Fixed missing module references in ftplugins.
- [x] Fixed LSP executable resolution with Mason-aware PATH handling.
- [x] Removed duplicate null-ls formatter registrations.
- [x] Removed stale Nix/Lean/model-checker keymaps.
- [x] Refreshed core markdown documentation to match current behavior.
