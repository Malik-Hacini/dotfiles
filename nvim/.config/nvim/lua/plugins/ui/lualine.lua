return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = true,
  event = { "VimEnter" },
  config = function()
    local function setup_lualine()
      local theme = vim.g.theme_switch_colorscheme == "pywal16" and "pywal16-nvim" or "auto"

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = theme,
          globalstatus = false,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "starter" },
            winbar = {},
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end

    setup_lualine()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("LualineThemeRefresh", { clear = true }),
      callback = function()
        vim.schedule(setup_lualine)
      end,
      desc = "Refresh lualine theme after colorscheme changes",
    })
  end,
}
