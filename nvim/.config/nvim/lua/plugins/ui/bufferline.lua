return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = true,
  event = {"VimEnter"},
  config = function()
    local bufferline = require("bufferline")

    local function highlight_color(group_name, key, fallback)
      local ok, highlight = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
      if not ok or not highlight or not highlight[key] then
        return fallback
      end

      return string.format("#%06x", highlight[key])
    end

    local function get_colors()
      return {
        text = highlight_color("Normal", "fg", "#cdd6f4"),
        muted = highlight_color("Comment", "fg", "#7f849c"),
        mid = highlight_color("StatusLine", "bg", highlight_color("NormalFloat", "bg", "#1e1e2e")),
        light = highlight_color("CursorLine", "bg", "#313244"),
        accent = highlight_color("Function", "fg", "#cba6f7"),
      }
    end

    local function get_zen_padding()
      local view = package.loaded["zen-mode.view"]
      if not view or not view.is_open or not view.is_open() then
        return { left = 0, right = 0 }
      end

      if not view.opts then
        return { left = 0, right = 0 }
      end

      local layout = view.layout(view.opts)
      if not layout or layout.width >= vim.o.columns then
        return { left = 0, right = 0 }
      end

      -- Align the tabline region with the Zen writing width, leaving the outer
      -- columns on the normal background.
      local left_padding = math.max(0, layout.col)
      local zen_width = layout.width
      local right_padding = math.max(0, vim.o.columns - left_padding - zen_width)

      return { left = left_padding, right = right_padding }
    end

    local function make_tabline_padding(width, highlight)
      if width <= 0 then
        return nil
      end

      return { text = string.rep(" ", width), link = highlight }
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
        fill = { bg = "NONE" },
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
      }, colors.accent, colors.light)

      assign({
        "buffer_selected",
        "tab_selected",
        "numbers_selected",
      }, colors.accent, colors.light, { bold = true })

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
      }, colors.accent, colors.light)

      return groups
    end

    local function get_hl_value(group_name, key, fallback)
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
      if ok and hl and hl[key] then
        return hl[key]
      end
      return fallback
    end

    local function apply_selected_overline(colors)
      local overline = { sp = colors.accent, overline = true }
      local selected_groups = {
        BufferLineBufferSelected = { fg = colors.accent, bg = colors.light, bold = true },
        BufferLineNumbersSelected = { fg = colors.accent, bg = colors.light, bold = true },
        BufferLineCloseButtonSelected = { fg = colors.accent, bg = colors.light },
        BufferLineDiagnosticSelected = { fg = colors.accent, bg = colors.light },
        BufferLineDuplicateSelected = { fg = colors.accent, bg = colors.light },
        BufferLineModifiedSelected = {
          fg = get_hl_value("BufferLineModifiedSelected", "fg", colors.text),
          bg = colors.light,
        },
        BufferLineTabSelected = { fg = colors.accent, bg = colors.light, bold = true },
        BufferLineTabSeparatorSelected = { fg = colors.light, bg = colors.light },
        BufferLineSeparatorSelected = { fg = colors.light, bg = colors.light },
      }

      for group_name, value in pairs(selected_groups) do
        vim.api.nvim_set_hl(0, group_name, vim.tbl_extend("force", value, overline))
      end

      local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
      if not devicons_ok then
        return
      end

      local seen = {}
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
          local path = vim.api.nvim_buf_get_name(bufnr)
          if path ~= "" then
            local filename = vim.fn.fnamemodify(path, ":t")
            local _, icon_hl = devicons.get_icon(filename, nil, { default = true })

            if icon_hl and not seen[icon_hl] then
              seen[icon_hl] = true
              vim.api.nvim_set_hl(0, "BufferLine" .. icon_hl .. "Selected", {
                fg = get_hl_value(icon_hl, "fg", colors.accent),
                bg = colors.light,
                sp = colors.accent,
                overline = true,
              })
            end
          end
        end
      end
    end

    local colors = get_colors()

    local function is_diffview_open()
      local ok, lib = pcall(require, "diffview.lib")
      return ok and lib.get_current_view() ~= nil
    end

    local function refresh_tabline_visibility()
      local should_hide = vim.bo.filetype == "alpha" or is_diffview_open()
      vim.opt.showtabline = should_hide and 0 or 2
    end

    local bufferline_options = {
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
        custom_areas = {
          left = function()
            local padding = get_zen_padding()
            local outer = make_tabline_padding(padding.left, "Normal")
            return outer and { outer } or {}
          end,
          right = function()
            local padding = get_zen_padding()
            local outer = make_tabline_padding(padding.right, "Normal")
            return outer and { outer } or {}
          end,
        },
        sort_by = function(buffer_a, buffer_b)
          return vim.fn.getftime(buffer_a.path) > vim.fn.getftime(buffer_b.path)
        end,
    }

    local function setup_bufferline()
      colors = get_colors()
      bufferline.setup({
        highlights = build_custom_highlights(colors),
        options = bufferline_options,
      })
    end

    setup_bufferline()

    local function set_tabline_hls()
      colors = get_colors()
      vim.api.nvim_set_hl(0, "TabLine", { fg = colors.muted, bg = colors.mid })
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TabLineSel", {
        fg = colors.accent,
        bg = colors.light,
        bold = true,
        sp = colors.accent,
        overline = true,
      })
      apply_selected_overline(colors)
    end

    set_tabline_hls()

    local aug = vim.api.nvim_create_augroup("BufferlineStyling", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = aug,
      callback = function()
        vim.schedule(function()
          setup_bufferline()
          set_tabline_hls()
        end)
      end,
      desc = "Reapply bufferline and tabline highlights",
    })

    vim.api.nvim_create_autocmd({ "BufAdd", "BufFilePost" }, {
      group = aug,
      callback = function()
        vim.schedule(function()
          apply_selected_overline(colors)
        end)
      end,
      desc = "Refresh bufferline selected icon highlights",
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      group = aug,
      desc = "Refresh tabline for alpha",
      callback = function()
        vim.schedule(refresh_tabline_visibility)
      end,
    })

    vim.api.nvim_create_autocmd("BufUnload", {
      group = aug,
      desc = "Refresh tabline after alpha",
      callback = function(args)
        if vim.api.nvim_buf_is_valid(args.buf)
            and vim.bo[args.buf].filetype == "alpha" then
          vim.schedule(refresh_tabline_visibility)
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "TabEnter", "BufEnter" }, {
      group = aug,
      callback = function()
        vim.schedule(refresh_tabline_visibility)
      end,
      desc = "Refresh tabline for current view",
    })

    vim.api.nvim_create_autocmd("User", {
      group = aug,
      pattern = {
        "DiffviewViewOpened",
        "DiffviewViewClosed",
        "DiffviewViewEnter",
        "DiffviewViewLeave",
      },
      callback = function()
        vim.schedule(refresh_tabline_visibility)
      end,
      desc = "Refresh tabline for Diffview",
    })

    refresh_tabline_visibility()

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
