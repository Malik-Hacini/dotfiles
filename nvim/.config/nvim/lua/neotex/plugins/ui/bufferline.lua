return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()
    local bufferline = require("bufferline")

    local palette_ok, palette = pcall(function()
      return require("catppuccin.palettes").get_palette("mocha")
    end)

    local colors = {
      text = "#cdd6f4",
      muted = "#7f849c",
      mid = "#1e1e2e",
      light = "#313244",
      dark = "#181825",
      accent = "#fab387",
    }

    if palette_ok and palette then
      colors.text = palette.text or colors.text
      colors.muted = palette.overlay1 or colors.muted
      colors.mid = palette.base or colors.mid
      colors.light = palette.surface0 or colors.light
      colors.dark = palette.mantle or colors.dark
      colors.accent = palette.peach or colors.accent
    end

    local ctp_ok, ctp_bufferline = pcall(require, "catppuccin.special.bufferline")
    local highlights = nil

    if ctp_ok then
      highlights = ctp_bufferline.get_theme({
        styles = {},
        custom = {
          all = {
            fill = { bg = colors.mid },

            background = { fg = colors.muted, bg = colors.mid },
            buffer_visible = { fg = colors.muted, bg = colors.mid },
            buffer_selected = { fg = colors.text, bg = colors.light, bold = true },

            tab = { fg = colors.muted, bg = colors.mid },
            tab_selected = { fg = colors.text, bg = colors.light, bold = true },
            tab_separator = { fg = colors.mid, bg = colors.mid },
            tab_separator_selected = { fg = colors.light, bg = colors.light },
            tab_close = { fg = colors.muted, bg = colors.mid },

            close_button = { fg = colors.muted, bg = colors.mid },
            close_button_visible = { fg = colors.muted, bg = colors.mid },
            close_button_selected = { fg = colors.text, bg = colors.light },

            modified = { fg = colors.accent, bg = colors.mid },
            modified_visible = { fg = colors.accent, bg = colors.mid },
            modified_selected = { fg = colors.accent, bg = colors.light },

            numbers = { fg = colors.muted, bg = colors.mid },
            numbers_visible = { fg = colors.muted, bg = colors.mid },
            numbers_selected = { fg = colors.text, bg = colors.light, bold = true },

            separator = { fg = colors.mid, bg = colors.mid },
            separator_visible = { fg = colors.mid, bg = colors.mid },
            separator_selected = { fg = colors.light, bg = colors.light },

            indicator_visible = { fg = colors.mid, bg = colors.mid },
            indicator_selected = { fg = colors.light, bg = colors.light },
            offset_separator = { fg = colors.dark, bg = colors.dark },

            diagnostic = { fg = colors.muted, bg = colors.mid },
            diagnostic_visible = { fg = colors.muted, bg = colors.mid },
            diagnostic_selected = { fg = colors.text, bg = colors.light },
          },
        },
      })
    end

    bufferline.setup({
      highlights = highlights,
      options = {
        mode = "buffers",
        custom_filter = function(buf_number)
          return vim.bo[buf_number].filetype ~= "qf"
        end,
        color_icons = false,
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
        offsets = {
          {
            filetype = "NvimTree",
            text = "",
            highlight = "NeoTreeOffset",
            text_align = "left",
            separator = false,
            padding = 1,
          },
        },
      },
    })

    local function set_tabline_hls()
      local function set_groups(groups, spec)
        for _, group in ipairs(groups) do
          vim.api.nvim_set_hl(0, group, spec)
        end
      end

      set_groups({
        "BufferLineBackground",
        "BufferLineBuffer",
        "BufferLineTab",
        "BufferLineTabClose",
        "BufferLineCloseButton",
        "BufferLineModified",
        "BufferLineNumbers",
        "BufferLineDiagnostic",
        "BufferLineError",
        "BufferLineErrorDiagnostic",
        "BufferLineWarning",
        "BufferLineWarningDiagnostic",
        "BufferLineInfo",
        "BufferLineInfoDiagnostic",
        "BufferLineHint",
        "BufferLineHintDiagnostic",
        "BufferLineDuplicate",
        "BufferLinePick",
        "BufferLineTruncMarker",
        "BufferLineGroupLabel",
        "BufferLineGroupSeparator",
      }, { fg = colors.muted, bg = colors.mid })

      set_groups({
        "BufferLineBufferVisible",
        "BufferLineTabVisible",
        "BufferLineCloseButtonVisible",
        "BufferLineModifiedVisible",
        "BufferLineNumbersVisible",
        "BufferLineDiagnosticVisible",
        "BufferLineErrorVisible",
        "BufferLineErrorDiagnosticVisible",
        "BufferLineWarningVisible",
        "BufferLineWarningDiagnosticVisible",
        "BufferLineInfoVisible",
        "BufferLineInfoDiagnosticVisible",
        "BufferLineHintVisible",
        "BufferLineHintDiagnosticVisible",
        "BufferLineDuplicateVisible",
        "BufferLinePickVisible",
      }, { fg = colors.muted, bg = colors.mid })

      set_groups({
        "BufferLineBufferSelected",
        "BufferLineTabSelected",
        "BufferLineCloseButtonSelected",
        "BufferLineModifiedSelected",
        "BufferLineNumbersSelected",
        "BufferLineDiagnosticSelected",
        "BufferLineErrorSelected",
        "BufferLineErrorDiagnosticSelected",
        "BufferLineWarningSelected",
        "BufferLineWarningDiagnosticSelected",
        "BufferLineInfoSelected",
        "BufferLineInfoDiagnosticSelected",
        "BufferLineHintSelected",
        "BufferLineHintDiagnosticSelected",
        "BufferLineDuplicateSelected",
        "BufferLinePickSelected",
      }, { fg = colors.text, bg = colors.light, bold = true })

      vim.api.nvim_set_hl(0, "BufferLineFill", { bg = colors.mid })
      vim.api.nvim_set_hl(0, "TabLine", { fg = colors.muted, bg = colors.mid })
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = colors.mid })
      vim.api.nvim_set_hl(0, "TabLineSel", { fg = colors.text, bg = colors.light, bold = true })
      vim.api.nvim_set_hl(0, "BufferLineSeparator", { fg = colors.mid, bg = colors.mid })
      vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { fg = colors.mid, bg = colors.mid })
      vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { fg = colors.light, bg = colors.light })
      vim.api.nvim_set_hl(0, "BufferLineTabSeparator", { fg = colors.mid, bg = colors.mid })
      vim.api.nvim_set_hl(0, "BufferLineTabSeparatorSelected", { fg = colors.light, bg = colors.light })
      vim.api.nvim_set_hl(0, "BufferLineIndicatorVisible", { fg = colors.mid, bg = colors.mid })
      vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = colors.light, bg = colors.light })
      vim.api.nvim_set_hl(0, "NeoTreeOffset", { fg = colors.muted, bg = colors.dark })
      vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { fg = colors.dark, bg = colors.dark })
    end

    set_tabline_hls()

    local aug = vim.api.nvim_create_augroup("NeoTexBufferlineStyling", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = aug,
      callback = function()
        vim.schedule(set_tabline_hls)
      end,
      desc = "Reapply bufferline and tabline highlights",
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      group = aug,
      callback = function()
        vim.defer_fn(set_tabline_hls, 10)
      end,
      desc = "Keep bufferline colors stable across focus changes",
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      desc = "Disable tabline for alpha",
      callback = function()
        vim.opt.showtabline = 0
      end,
    })

    vim.api.nvim_create_autocmd("BufUnload", {
      buffer = 0,
      desc = "Enable tabline after alpha",
      callback = function()
        vim.opt.showtabline = 2
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "qf",
      callback = function()
        vim.opt_local.buflisted = false
        vim.opt_local.bufhidden = "wipe"
      end,
    })
  end,
}
