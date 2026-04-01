local function colors_wal_path()
  local cache_home = vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")

  return cache_home .. "/wal/colors-wal.vim"
end

local function colors_signature()
  local stat = vim.loop.fs_stat(colors_wal_path())

  if stat and stat.mtime then
    return string.format("%s:%s", stat.mtime.sec, stat.mtime.nsec)
  end

  return ""
end

local function has_pywal_colors()
  return vim.fn.filereadable(colors_wal_path()) == 1
end

local function setup_catppuccin()
  require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = true,
    background = {
      dark = "mocha",
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      telescope = true,
      treesitter = true,
      mason = true,
      which_key = true,
    },
    highlight_overrides = {
      mocha = function(mocha)
        return {
          Comment = { fg = mocha.lavender },
          LineNr = { fg = mocha.overlay1 },
          CursorLineNr = { fg = mocha.lavender },
          NormalFloat = { bg = mocha.base },
          FloatBorder = { bg = mocha.base },
          FloatTitle = { bg = mocha.base },
        }
      end,
    },
  })
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      setup_catppuccin()
    end,
  },
  {
    "uZer/pywal16.nvim",
    name = "pywal16",
    priority = 1000,
    config = function()
      local last_signature = nil
      local augroup = vim.api.nvim_create_augroup("PywalColorscheme", { clear = true })

      local function apply_pywal_overrides()
        local ok, colors = pcall(require("pywal16.core").get_colors)
        if not ok or not colors then
          return
        end

        vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.foreground, bg = colors.background })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.foreground, bg = colors.background })
        vim.api.nvim_set_hl(0, "FloatTitle", { fg = colors.foreground, bg = colors.background })
      end

      local function apply_colorscheme(force)
        local signature = colors_signature()

        if not force and vim.g.theme_switch_colorscheme == "pywal16" and signature ~= "" and signature == last_signature then
          return
        end

        if has_pywal_colors() then
          local ok = pcall(function()
            require("pywal16").setup()
            vim.cmd.colorscheme("pywal16")
            vim.g.theme_switch_colorscheme = "pywal16"
            apply_pywal_overrides()
          end)

          if ok then
            last_signature = signature
            return
          end
        end

        pcall(vim.cmd.colorscheme, "catppuccin-nvim")
        vim.g.theme_switch_colorscheme = "catppuccin"
        last_signature = ""
      end

      apply_colorscheme(true)

      vim.api.nvim_create_user_command("PywalRefresh", function()
        apply_colorscheme(true)
      end, { desc = "Refresh Pywal16 colors" })

      vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
        group = augroup,
        callback = function()
          vim.schedule(function()
            apply_colorscheme(false)
          end)
        end,
        desc = "Refresh colorscheme after pywal changes",
      })
    end,
  },
}

-- -- MONOKAI
-- return {
--   "tanvirtin/monokai.nvim",  -- Monokai theme
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("monokai").setup {
--       -- palette = require("monokai").pro,  -- Use Monokai Pro palette
--     }
--   vim.cmd("colorscheme monokai")
--   end
-- }

-- -- KANAGAWA
-- return {
--   "rebelot/kanagawa.nvim",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require('kanagawa').setup({
--       compile = false,  -- enable compiling the colorscheme
--       undercurl = true, -- enable undercurls
--       commentStyle = { italic = true },
--       functionStyle = {},
--       keywordStyle = { italic = true },
--       statementStyle = { bold = true },
--       typeStyle = {},
--       transparent = false,   -- do not set background color
--       dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
--       terminalColors = true, -- define vim.g.terminal_color_{0,17}
--       colors = {
--         -- add/modify theme and palette colors
--         palette = {},
--         theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
--       },
--       overrides = function(colors) -- add/modify highlights
--         return {}
--       end,
--       theme = "wave", -- Load "wave" theme when 'background' option is not set
--       background = {
--         -- map the value of 'background' option to a theme
--         dark = "wave", -- try "dragon" !
--         light = "lotus"
--       },
--     })
--     vim.cmd("colorscheme kanagawa") -- setup must be called before loading
--   end,
-- }



-- -- NIGHTFLY
-- return {
--   "bluz71/vim-nightfly-guicolors",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     -- load the colorscheme here
--     vim.cmd("colorscheme nightfly")
--   end,
-- }


-- OTHER
-- "luisiacc/gruvbox-baby"
-- "folke/tokyonight.nvim"
-- "lunarvim/darkplus.nvim"
-- "navarasu/onedark.nvim"
-- "savq/melange"
-- "EdenEast/nightfox.nvim"
