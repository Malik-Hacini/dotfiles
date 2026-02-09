
-----------------------------------------------------------
-- Typst plugins 
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
local typst_preview = safe_require("neotex.plugins.typst.typst-preview")
local luasnip = safe_require("neotex.plugins.typst.luasnip")
local typst_vim = safe_require("neotex.plugins.typst.typst-vim")

-- Return plugin specs
return {
  typst_preview,
  luasnip,
  typst_vim
 }
