-- neotex/plugins/typst/typst.vim.lua
-- Plugin specification for kaarmu/typst.vim

return {
  "kaarmu/typst.vim",
  ft = "typst",
  lazy = false,   -- you might want to make this true if you only want it to load when a typst file is opened
  config = function()
    -- Typical settings; adjust to your preferences

    -- Enable syntax highlighting (default is 1)
    vim.g.typst_syntax_highlight = 1

    -- Path to the typst executable (if not in your PATH already)
    -- vim.g.typst_cmd = "typst"

    -- PDF viewer for previewing exports
    vim.g.typst_pdf_viewer = "zathura"  -- or whatever you use

    -- Conceal options (make math symbols, emojis, etc. more visual or "clean")
    vim.g.typst_conceal = 1
    vim.g.typst_conceal_math = 1
    vim.g.typst_conceal_emoji = 1

    -- Other settings from the plugin that you may want to enable
    -- e.g. embedded languages code blocks highlighting
    -- vim.g.typst_embedded_languages = { "rust", "python" }  -- example

    -- Folding options
    vim.g.typst_folding = 0
    vim.g.typst_foldnested = 1

    -- Auto-open quickfix when there are errors
    vim.g.typst_auto_open_quickfix = 1

    -- Optionally autoclose TOC (table of contents) window/view
    vim.g.typst_auto_close_toc = 0
  end,
}

