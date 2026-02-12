# Utility Modules

Shared helper modules used across NeoTex.

## Modules

- `init.lua`: loads utility modules and runs each `setup()`
- `buffer.lua`: buffer navigation and config reload helpers
- `fold.lua`: folding state helpers and global folding utilities
- `url.lua`: URL detection/opening helpers (`gx`, Ctrl+Click workflow)
- `diagnostics.lua`: diagnostic UI helpers and clipboard export
- `misc.lua`: small utility functions and user commands
- `optimize.lua`: startup/plugin profiling commands
- `lectic_extras.lua`: helper commands for Lectic file creation/submission

## User Commands Defined by Util Modules

- `:ReloadConfig`
- `:BufCloseOthers`
- `:BufCloseUnused [minutes]`
- `:BufSaveAll`
- `:ToggleLineNumbers`
- `:TrimWhitespace`
- `:SelectionInfo`
- `:AnalyzeStartup`
- `:ProfilePlugins`
- `:OptimizationReport`
- `:SuggestLazyLoading`
- `:LecticCreateFile`
- `:LecticSubmitSelection`

## Backward-Compatible Globals

Some helpers are exposed on `_G` for compatibility with existing mappings/workflows, including folding, URL, diagnostics, and checkbox helpers.

When adding new utility behavior, prefer module functions first and expose `_G` aliases only when required for compatibility.
