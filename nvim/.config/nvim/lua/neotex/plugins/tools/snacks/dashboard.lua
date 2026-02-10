local M = {}

M.preset = {
  pick = nil,
  keys = {
    { icon = " ", key = "s", desc = "Restore Session", action = ":SessionManager load_session" },
    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
    { icon = " ", key = "e", desc = "Explorer", action = ":NvimTreeToggle" },
    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
    { icon = "󰱼 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
    { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
    { icon = " ", key = "i", desc = "Info", action = ":e ~/.config/CheatSheet.md" },
    { icon = " ", key = "m", desc = "Manage Plugins", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
    { icon = " ", key = "h", desc = "Checkhealth", action = ":checkhealth" },
    { icon = " ", key = "q", desc = "Quit", action = ":qa!" },
  },
  header = (function()
    local lines = {
      "         ████ ██████           █████      ██                    ",
      "        ███████████             █████                            ",
      "        █████████ ███████████████████ ███   ███████████  ",
      "       █████████  ███    █████████████ █████ ██████████████  ",
      "      █████████ ██████████ █████████ █████ █████ ████ █████  ",
      "    ███████████ ███    ███ █████████ █████ █████ ████ █████ ",
      "   ██████  █████████████████████ ████ █████ █████ ████ ██████",
    }
    local max_w = 0
    for _, l in ipairs(lines) do
      local w = vim.api.nvim_strwidth(l)
      if w > max_w then max_w = w end
    end
    for i, l in ipairs(lines) do
      lines[i] = l .. string.rep(" ", max_w - vim.api.nvim_strwidth(l))
    end
    return "\n" .. table.concat(lines, "\n") .. "\n"
  end)(),
}

M.sections = {
  { section = 'header' },
  { section = "keys", gap = 0, padding = 0},
  { section = 'startup' },
}

return M
