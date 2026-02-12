-- Snacks utility functions
local M = {}

-- Safe lazygit launcher with fallback
-- Prefer lazygit.nvim command and fall back to ToggleTerm if needed.
M.safe_lazygit = function()
  if vim.fn.exists(":LazyGit") == 2 then
    vim.cmd("LazyGit")
  else
    vim.cmd('TermExec cmd="lazygit" direction=float')
  end
end

return M
