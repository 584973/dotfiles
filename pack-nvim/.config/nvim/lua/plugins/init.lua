vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/stevearc/conform.nvim",
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.1" },
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/mfussenegger/nvim-lint",
  "https://github.com/folke/tokyonight.nvim"
})

require("plugins.ui")
require("plugins.fuzzy")
require("plugins.formatting")
require("plugins.completion")
require("plugins.linting")
