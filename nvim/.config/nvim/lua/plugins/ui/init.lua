-----------------------------------------------------------
-- UI Enhancement Plugins
-- 
-- This module loads plugins that enhance the UI experience:
-- - colorscheme.lua: Catppuccin theme configuration
-- - lualine.lua: Status line configuration
-- - bufferline.lua: Buffer line configuration
-- - nvim-web-devicons.lua: File icons
-- - sessions.lua: Session management
--
-- The module uses a consistent error handling approach to ensure
-- NeoVim starts properly even if some plugin specifications fail.
-----------------------------------------------------------

-- Helper function to require a module with error handling
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load plugin module: " .. module, vim.log.levels.WARN)
    return {}
  end
  return result
end

-- Load modules
local colorscheme_module = safe_require("plugins.ui.colorscheme")
local lualine_module = safe_require("plugins.ui.lualine")
local bufferline_module = safe_require("plugins.ui.bufferline")
local web_devicons_module = safe_require("plugins.ui.nvim-web-devicons")
local sessions_module = safe_require("plugins.ui.sessions")

local function append_specs(specs, module)
  if type(module) ~= "table" then
    return
  end

  if module[1] ~= nil and type(module[1]) == "table" then
    for _, spec in ipairs(module) do
      table.insert(specs, spec)
    end
    return
  end

  table.insert(specs, module)
end

local specs = {}
append_specs(specs, colorscheme_module)
append_specs(specs, lualine_module)
append_specs(specs, bufferline_module)
append_specs(specs, web_devicons_module)
append_specs(specs, sessions_module)

return specs
