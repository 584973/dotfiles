return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set("n", "<leader>tt", ":ToggleTerm direction=float name=Floaty<cr>" ,{})
    end,
  },
}
