return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- local lspconfig = require("lspconfig") -- DEPRECATED
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local default = cmp_nvim_lsp.default_capabilities()

    -- DIAGNOSTICS CONFIGURATION
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    vim.diagnostic.config({
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- PYTHON SERVER
    vim.lsp.config("pyright", {
      capabilities = default,
       settings = {
        python = {
          analysis = {
            -- I moved your custom python paths here where they belong
            extraPaths = { "/home/benjamin/Documents/Philosophy/Projects/ModelChecker/Code/src" },
            typeCheckingMode = "basic",
          }
        },
      },
    })
    vim.lsp.enable("pyright")

    -- LATEX SERVER (Fixed: Removed Python settings from here)
    vim.lsp.config("texlab", {
      capabilities = default,
      settings = {
        texlab = {
          build = {
            onSave = true,
          },
          chktex = {
            onEdit = false,
            onOpenAndSave = false,
          },
          diagnosticsDelay = 300,
        },
      },
    })
    vim.lsp.enable("texlab")

    -- TYPST SERVER
    -- Ensure you have run :Lazy update for this to work
    vim.lsp.config("tinymist", {
        capabilities = default,
        single_file_support = true,
    })
    vim.lsp.enable("tinymist")

    -- LUA SERVER
    vim.lsp.config("lua_ls", {
      capabilities = default,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end,
}
