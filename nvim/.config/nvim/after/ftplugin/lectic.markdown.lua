-- Buffer-local settings for lectic.markdown files

-- Import markdown settings
-- Reuse markdown.lua configuration if it exists
local markdown_path = vim.fn.stdpath("config") .. "/after/ftplugin/markdown.lua"
if vim.fn.filereadable(markdown_path) == 1 then
  dofile(markdown_path)
end

-- Markdown settings are loaded from markdown.lua via dofile() above
-- Only add lectic-specific settings here

-- Load the saved folding state instead
local ok_fold, fold_utils = pcall(require, "neotex.util.fold")
if ok_fold and type(fold_utils) == "table" and type(fold_utils.load_folding_state) == "function" then
  fold_utils.load_folding_state()
elseif _G.LoadFoldingState then
  _G.LoadFoldingState()
end

-- Make sure that we inherit markdown settings
vim.cmd [[
  runtime! syntax/markdown.vim
  runtime! indent/markdown.vim
]]

-- Handle checkbox for Lectic files
function _G.HandleCheckbox()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*%-%s%[[ x]%]") then
    -- Toggle between [ ] and [x]
    if line:match("%[ %]") then
      vim.cmd("s/\\[ \\]/[x]/e")
    else
      vim.cmd("s/\\[x\\]/[ ]/e")
    end
  end
end

-- Additional keymaps specific to lectic.markdown
vim.keymap.set("n", "<C-n>", ":lua HandleCheckbox()<CR>",
  { buffer = true, silent = true, desc = "Toggle checkbox" })
