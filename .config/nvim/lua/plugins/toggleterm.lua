return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set("n", "<leader>tt", ":ToggleTerm direction=horizontal name=Floaty<cr>" ,{})
    end,
  },
}
