-----------------------------------------------------------
-- NeoVim Configuration Bootstrapping
-- Maintained in this dotfiles repo.
-- 
-- This module handles the initialization of the NeoVim configuration.
-- It provides a robust sequence of steps to set up the environment,
-- load plugins, and initialize core functionality with proper error
-- handling at each step.
-----------------------------------------------------------

local M = {}

-- Utility function for error handling
local function with_error_handling(func, msg)
  local ok, err = pcall(func)
  if not ok then
    vim.notify("Error in " .. msg .. ": " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Ensure lazy.nvim is installed
local function ensure_lazy()
  return with_error_handling(function()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)
  end, "installation of lazy.nvim")
end

-- Initialize lazy.nvim with plugin specs
local function setup_lazy()
  return with_error_handling(function()
    require("plugins")

    require("lazy").setup({
      { import = "plugins.lsp" },
      { import = "plugins.editor" },
      { import = "plugins.tools" },
      { import = "plugins.text" },
      { import = "plugins.ui" },
      { import = "plugins.typst" },
    }, {
      defaults = {
        version = "*",
      },
      install = {
        colorscheme = { "aether" },
      },
      checker = {
        enabled = true,
        notify = false,
      },
      change_detection = {
        notify = false,
      },
      performance = {
        reset_packpath = true,
        rtp = {
          reset = true,
        },
      },
      rocks = {
        enabled = false,
      },
    })
  end, "setup of lazy.nvim plugins")
end

-- Initialize utilities with error handling
local function setup_utils()
  return with_error_handling(function()
    local utils = require("util")
    if type(utils) == "table" and utils.setup then
      utils.setup()
    end
  end, "setup of utilities")
end

-- Main initialization function
function M.init()
  local steps = {
    { func = ensure_lazy, name = "Ensure lazy.nvim is installed" },
    { func = setup_lazy, name = "Set up plugins with lazy.nvim" },
    { func = setup_utils, name = "Initialize utility functions" },
  }
  
  local success = true
  for _, step in ipairs(steps) do
    if not step.func() then
      vim.notify("Failed at step: " .. step.name, vim.log.levels.ERROR)
      success = false
      break
    end
  end
  
  if not success then
    -- Only notify on errors
    vim.notify("Neovim configuration loaded with errors", vim.log.levels.WARN)
  end
  
  return success
end

-- Return the module, let init.lua call M.init()
return M
