local theme_file = vim.fn.expand("~/.config/omarchy/neovim-theme.lua")
local ok, theme = pcall(dofile, theme_file)

if ok and type(theme) == "table" then
  return theme
end

return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    priority = 1000,
    config = function()
      require("aether").setup({ transparent = true })
      vim.cmd.colorscheme("aether")
    end,
  },
}
