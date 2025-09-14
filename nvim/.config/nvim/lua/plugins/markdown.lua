return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  keys = {
    { "<leader>ma", ":MarkdownPreview<CR>", desc = "Markdown: start preview" },
    { "<leader>mc", ":MarkdownPreviewStop<CR>", desc = "Markdown: stop preview" },
    { "<leader>mt", ":MarkdownPreviewToggle<CR>", desc = "Markdown: toggle preview" },
  },
}
