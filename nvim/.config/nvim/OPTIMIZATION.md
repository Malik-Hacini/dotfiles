# NeoTex Optimization Guide

This document tracks the current optimization strategy for NeoTex.

## Goals

- Keep startup predictable and quiet.
- Load heavy features on demand.
- Avoid duplicate providers for the same job unless intentional.
- Keep diagnostics/formatting fast and executable-aware.

## Current Baseline Practices

- Plugin categories are split by domain (`editor`, `tools`, `text`, `ui`, `typst`, `lsp`).
- Most plugins use lazy triggers (`event`, `ft`, `cmd`, `keys`).
- Mason binaries are added to Neovim PATH at startup for reliable tool resolution.
- LSP activation is executable-gated to prevent noisy failures.
- Formatting is centralized in conform.nvim; null-ls is scoped and deduplicated.
- Linters are enabled only when their executables are available.

## Profiling Commands

- `:AnalyzeStartup` - startup-time report
- `:ProfilePlugins` - plugin load profiling
- `:OptimizationReport` - combined report
- `:SuggestLazyLoading` - lazy-loading suggestions

Run these before and after changes to validate impact.

## Practical Workflow

1. Run `:AnalyzeStartup` and `:ProfilePlugins`.
2. Identify top contributors (startup-loaded plugins, expensive config blocks).
3. Apply one change at a time:
   - move to lazy trigger
   - defer non-critical setup with `vim.defer_fn`
   - remove duplicate integrations
4. Re-run profiling commands.
5. Keep only changes with measurable wins and no UX regressions.

## Common Hotspots

- Completion stacks (`nvim-cmp` + sources)
- File explorer and tree rendering
- Broad BufRead autocommands
- Multiple formatter/linter backends on the same filetype
- Verbose startup notifications

## Guardrails

- Avoid enabling unknown Mason LSP servers globally.
- Avoid duplicate source registration in null-ls.
- Prefer executable checks over unconditional linter/formatter setup.
- Keep docs aligned after optimization changes (README + AGENTS + module README).
