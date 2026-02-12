return {
  "nvimtools/none-ls.nvim",               -- configure formatters & linters
  lazy = true,
  ft = { "python", "html", "javascript", "typescript", "lua" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
  },
  config = function()
    if vim.g._neotex_null_ls_setup then
      return
    end
    vim.g._neotex_null_ls_setup = true

    local null_ls = require("null-ls")
    local null_ls_utils = require("null-ls.utils")
    local formatting = null_ls.builtins.formatting

    null_ls.setup({
      debug = false,
      root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
      sources = {
        -- Lua
        formatting.stylua.with({
          extra_args = {
            "--quote-style", "AutoPreferDouble",
            "--indent-type", "Spaces",
            "--indent-width", "2",
          },
        }),
        -- Python
        formatting.isort.with({
          extra_args = { "--profile", "black" },
        }),
        formatting.black.with({
          extra_args = { "--fast", "--line-length", "88" },
        }),
      },
    })
  end,
}
