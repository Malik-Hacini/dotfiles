return {
  "nvimtools/none-ls.nvim",               -- configure formatters & linters
  lazy = true,
  ft = { "python", "html", "javascript", "typescript", "lua" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    "williamboman/mason.nvim",
  },
  config = function()
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        "stylua",   -- lua formatter
        "isort",    -- python formatter
        "black",    -- python formatter
        "pylint",   -- python linter (used by nvim-lint, not none-ls)
      },
      automatic_installation = true,
      handlers = {
        -- Prevent mason-null-ls from auto-registering pylint diagnostics;
        -- pylint is handled by nvim-lint instead
        pylint = function() end,
      },
    })

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
