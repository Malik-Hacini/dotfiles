return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "sh -c 'cd app && NODE_ENV=production npx --yes yarn install'",
  keys = {
    { "<leader>mo", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "open markdown preview" },
  },
  init = function()
    vim.g.mkdp_browser = "qutebrowser"

    -- Echo preview page url in command line when opening preview page
    vim.g.mkdp_echo_preview_url = 1

    -- Don't auto-open preview when entering markdown buffer
    vim.g.mkdp_auto_start = 0

    -- Auto-close preview when leaving markdown buffer
    vim.g.mkdp_auto_close = 1

    -- Preview page title
    vim.g.mkdp_page_title = "${name}"

    -- Dark theme
    vim.g.mkdp_theme = "dark"

    -- Live refresh as you type in any mode
    vim.g.mkdp_refresh_slow = 0
  end,
}
