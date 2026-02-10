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

    -- Helper: only enable an LSP server if its binary is on PATH
    local function enable_if_executable(server_name, cmd)
      cmd = cmd or server_name
      if vim.fn.executable(cmd) == 1 then
        vim.lsp.enable(server_name)
      end
    end

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
            typeCheckingMode = "basic",
          }
        },
      },
    })
    enable_if_executable("pyright", "pyright-langserver")

    -- LATEX SERVER
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
    enable_if_executable("texlab")

    -- TYPST SERVER
    -- Ensure you have run :Lazy update for this to work
    vim.lsp.config("tinymist", {
        capabilities = default,
        single_file_support = true,
    })
    enable_if_executable("tinymist")

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
    enable_if_executable("lua_ls", "lua-language-server")
  end,
}
