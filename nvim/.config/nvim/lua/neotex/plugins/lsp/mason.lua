return {
  "williamboman/mason.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },

  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- import mason-tool-installer
    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- Keep the LSP server set explicit and predictable.
      ensure_installed = {
        "pyright",
        "texlab",
        "tinymist",
        "lua_ls",
      },
      -- Avoid auto-enabling unexpected servers.
      automatic_installation = false,
      automatic_enable = { "pyright", "texlab", "tinymist", "lua_ls" },
      handlers = {
        -- Default handler: only enable servers we explicitly configure in lspconfig.
        -- This prevents Mason-installed formatters/linters (stylua, black, etc.)
        -- from being accidentally started as LSP servers.
        function(server_name)
          local configured_servers = { "pyright", "texlab", "tinymist", "lua_ls" }
          for _, s in ipairs(configured_servers) do
            if server_name == s then
              -- Server is already configured and enabled in lspconfig.lua,
              -- so we just need to register its config (without re-enabling).
              return
            end
          end
          -- Unknown server discovered by mason-lspconfig: skip it silently.
        end,
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- LSP servers
        "pyright",
        "texlab",
        "tinymist",
        "lua-language-server",

        -- Formatters
        "stylua",
        "isort",
        "black",
        "prettier",
        "clang-format",
        "shfmt",

        -- Linters / diagnostics tools
        "pylint",
        "eslint_d",
        "stylelint",
        "jsonlint",
        "yamllint",
        "markdownlint",
        "shellcheck",
        "selene",
        "htmlhint",
        "cpplint",

        -- Notebook tooling
        "jupytext",
      },
    })
  end,
}
