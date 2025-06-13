return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  config = function()
    -- Keymaps for default tests (using Jest)
    vim.keymap.set("n", "<leader>t", ":TestNearest<CR>")
    vim.keymap.set("n", "<leader>T", ":TestFile<CR>")
    vim.keymap.set("n", "<leader>l", ":TestLast<CR>")
    vim.keymap.set("n", "<leader>g", ":TestVisit<CR>")

    -- Strategy
    vim.cmd("let test#strategy = 'vimux'")

    -- Default JavaScript runner (Jest)
    vim.cmd("let g:test#javascript#runner = 'jest'")

    -- Custom Playwright command
    vim.keymap.set("n", "<leader>åp", function()
      local file = vim.fn.expand("%")
      local cmd = "npx playwright test " .. file
      vim.cmd("VimuxRunCommand('" .. cmd .. "')")
    end, { desc = "Run Playwright test for current file" })
  end,
}

