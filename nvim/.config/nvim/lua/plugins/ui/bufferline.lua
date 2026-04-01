return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  lazy = true,
  event = { "VimEnter" },
  config = function()
    local bufferline = require("bufferline")

    local function get_colors()
      local colors = {
        text = "#cdd6f4",
        muted = "#7f849c",
        mid = "#1e1e2e",
        light = "#313244",
        accent = "#fab387",
      }

      local pywal_ok, pywal_colors = pcall(function()
        return require("pywal16.core").get_colors()
      end)

      if pywal_ok and pywal_colors and vim.g.theme_switch_colorscheme == "pywal16" then
        colors.text = pywal_colors.foreground or colors.text
        colors.muted = pywal_colors.color8 or colors.muted
        colors.mid = pywal_colors.background or colors.mid
        colors.light = pywal_colors.color0 or colors.light
        colors.accent = pywal_colors.color5 or colors.accent

        return colors
      end

      local palette_ok, palette = pcall(function()
        return require("catppuccin.palettes").get_palette("mocha")
      end)

      if palette_ok and palette then
        colors.text = palette.text or colors.text
        colors.muted = palette.overlay1 or colors.muted
        colors.mid = palette.base or colors.mid
        colors.light = palette.surface0 or colors.light
        colors.accent = palette.peach or colors.accent
      end

      return colors
    end

    local function make_hl(fg, bg, extra)
      local hl = { fg = fg, bg = bg }
      if extra then
        hl = vim.tbl_extend("force", hl, extra)
      end
      return hl
    end

    local function build_custom_highlights(colors)
      local groups = {
        fill = { bg = colors.mid },
      }

      local function assign(names, fg, bg, extra)
        for _, name in ipairs(names) do
          groups[name] = make_hl(fg, bg, extra)
        end
      end

      assign({
        "background",
        "buffer_visible",
        "tab",
        "tab_close",
        "close_button",
        "close_button_visible",
        "duplicate",
        "duplicate_visible",
        "numbers",
        "numbers_visible",
        "trunc_marker",
        "diagnostic",
        "diagnostic_visible",
      }, colors.muted, colors.mid)

      assign({
        "close_button_selected",
        "duplicate_selected",
        "diagnostic_selected",
      }, colors.text, colors.light)

      assign({
        "buffer_selected",
        "tab_selected",
        "numbers_selected",
      }, colors.text, colors.light, { bold = true })

      assign({
        "tab_separator",
        "separator",
        "separator_visible",
        "offset_separator",
        "indicator_visible",
      }, colors.mid, colors.mid)

      assign({
        "tab_separator_selected",
        "separator_selected",
        "indicator_selected",
      }, colors.light, colors.light)

      assign({ "modified", "modified_visible" }, colors.accent, colors.mid)
      groups.modified_selected = make_hl(colors.accent, colors.light)

      return groups
    end

    local function get_bufferline_highlights(colors)
      if vim.g.theme_switch_colorscheme == "pywal16" then
        return build_custom_highlights(colors)
      end

      local ctp_ok, ctp_bufferline = pcall(require, "catppuccin.special.bufferline")
      if not ctp_ok then
        return build_custom_highlights(colors)
      end

      return ctp_bufferline.get_theme({
        styles = {},
        custom = {
          all = build_custom_highlights(colors),
        },
      })
    end

    local function set_tabline_hls(colors)
      vim.api.nvim_set_hl(0, "TabLine", { fg = colors.muted, bg = colors.mid })
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = colors.mid })
      vim.api.nvim_set_hl(0, "TabLineSel", { fg = colors.text, bg = colors.light, bold = true })
    end

    local function apply_theme()
      local colors = get_colors()

      bufferline.setup({
        highlights = get_bufferline_highlights(colors),
        options = {
          mode = "buffers",
          custom_filter = function(buf_number)
            return vim.bo[buf_number].filetype ~= "qf"
          end,
          color_icons = true,
          separator_style = { "", "" },
          indicator = { style = "none" },
          buffer_close_icon = "󰅖",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          diagnostics = false,
          diagnostics_update_in_insert = false,
          show_tab_indicators = false,
          show_close_icon = false,
          show_buffer_close_icons = true,
          hover = { enabled = false },
          sort_by = function(buffer_a, buffer_b)
            return vim.fn.getftime(buffer_a.path) > vim.fn.getftime(buffer_b.path)
          end,
        },
      })

      set_tabline_hls(colors)
    end

    apply_theme()

    local aug = vim.api.nvim_create_augroup("BufferlineStyling", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = aug,
      callback = function()
        vim.schedule(apply_theme)
      end,
      desc = "Reapply bufferline and tabline highlights",
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      group = aug,
      desc = "Disable tabline for alpha",
      callback = function()
        vim.opt.showtabline = 0
      end,
    })

    vim.api.nvim_create_autocmd("BufUnload", {
      group = aug,
      desc = "Enable tabline after alpha",
      callback = function(args)
        if vim.api.nvim_buf_is_valid(args.buf)
            and vim.bo[args.buf].filetype == "alpha" then
          vim.opt.showtabline = 2
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = aug,
      pattern = "qf",
      callback = function()
        vim.opt_local.buflisted = false
        vim.opt_local.bufhidden = "wipe"
      end,
    })
  end,
}
