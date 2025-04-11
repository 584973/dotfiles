return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          filtered_items = {
            visible = true,
            show_hidden_count = true,
            hide_dotfiles = false,
            hide_gitignore = false,
          },
        },
      })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>e",
        ":Neotree source=filesystem reveal=true position=float toggle=true<CR> ",
        { noremap = true, silent = true }
      )
    end,
  },
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end,
    vim.keymap.set("n", "b", "<CMD>Oil<CR>", { desc = "Open parent directory" }),
  },
}
