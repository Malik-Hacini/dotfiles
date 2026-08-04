local colors = {}
local theme_path = (os.getenv("HOME") or "") .. "/.local/state/omarchy/current/theme/colors.toml"

local file = io.open(theme_path, "r")
if file then
  for line in file:lines() do
    local key, value = line:match('^([%w_]+)%s*=%s*"([^"]+)"')
    if key and value then
      colors[key] = value
    end
  end
  file:close()
end

local function color(key, fallback)
  return colors[key] or fallback
end

local opts = {
  transparent = true,
  colors = {
    bg = color("background", "#1a1d24"),
    dark_bg = color("dark_background", "#13161c"),
    darker_bg = color("darker_background", "#0e1015"),
    lighter_bg = color("lighter_background", "#242830"),
    fg = color("foreground", "#a2aebb"),
    dark_fg = color("dark_foreground", "#6b7688"),
    light_fg = color("light_foreground", "#c0ccd5"),
    bright_fg = color("bright_foreground", "#dfe6eb"),
    muted = color("muted", "#4a5366"),
    red = color("red", "#ad523c"),
    yellow = color("yellow", "#d4a05a"),
    orange = color("orange", "#c47a4e"),
    green = color("green", "#5e9a7e"),
    cyan = color("cyan", "#5b9ea0"),
    blue = color("blue", "#5a8faa"),
    purple = color("magenta", "#8b6e9e"),
    brown = color("brown", "#7d5440"),
    bright_red = color("bright_red", "#c46e5a"),
    bright_yellow = color("bright_yellow", "#e0b87a"),
    bright_green = color("bright_green", "#7eb89a"),
    bright_cyan = color("bright_cyan", "#7ebcbe"),
    bright_blue = color("bright_blue", "#7aaac2"),
    bright_purple = color("bright_magenta", "#a68eba"),
    accent = color("accent", "#ad523c"),
    cursor = color("cursor", "#a2aebb"),
    foreground = color("foreground", "#a2aebb"),
    background = color("background", "#1a1d24"),
    selection = color("selection", "#2c3040"),
    selection_foreground = color("selection_foreground", "#dfe6eb"),
    selection_background = color("selection_background", "#4a5366"),
  },
}

return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = opts,
    config = function(_, plugin_opts)
      vim.o.background = colors.mode == "light" and "light" or "dark"
      require("aether").setup(plugin_opts)
      vim.cmd.colorscheme("aether")
    end,
  },
}
