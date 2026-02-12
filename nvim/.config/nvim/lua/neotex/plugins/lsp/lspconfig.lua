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

    -- Ensure Mason binaries are available to executable checks and LSP cmd lookup.
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if vim.fn.isdirectory(mason_bin) == 1 then
      vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
    end

    local function resolve_executable(cmd)
      if vim.fn.executable(cmd) == 1 then
        return cmd
      end

      local mason_cmd = mason_bin .. "/" .. cmd
      if vim.fn.executable(mason_cmd) == 1 then
        return mason_cmd
      end

      return nil
    end

    -- Helper: only enable an LSP server if its binary is available.
    local function enable_if_executable(server_name, cmd)
      if resolve_executable(cmd or server_name) then
        vim.lsp.enable(server_name)
      end
    end

    -- Explicitly keep formatter CLIs from attaching as LSP servers.
    pcall(vim.lsp.disable, "stylua")

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
    local pyright_cmd = resolve_executable("pyright-langserver")
    vim.lsp.config("pyright", {
      capabilities = default,
      cmd = pyright_cmd and { pyright_cmd, "--stdio" } or nil,
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
    local texlab_cmd = resolve_executable("texlab")
    vim.lsp.config("texlab", {
      capabilities = default,
      cmd = texlab_cmd and { texlab_cmd } or nil,
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
    local tinymist_cmd = resolve_executable("tinymist")
    vim.lsp.config("tinymist", {
        capabilities = default,
        cmd = tinymist_cmd and { tinymist_cmd } or nil,
        single_file_support = true,
    })
    enable_if_executable("tinymist")

    -- LUA SERVER
    local lua_ls_cmd = resolve_executable("lua-language-server")
    vim.lsp.config("lua_ls", {
      capabilities = default,
      cmd = lua_ls_cmd and { lua_ls_cmd } or nil,
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
