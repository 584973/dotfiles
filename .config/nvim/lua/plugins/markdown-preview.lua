return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,

  vim.keymap.set("n", "<leader>ma", ":MarkdownPreview<CR>", {}),
  vim.keymap.set("n", "<leader>mc", ":MarkdownPreviewStop<CR>", {}),
  vim.keymap.set("n", "<leader>mt", ":MarkdownPreviewToggle<CR>", {}),
}
