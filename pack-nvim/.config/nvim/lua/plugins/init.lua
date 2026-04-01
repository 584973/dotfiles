vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/stevearc/conform.nvim",
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.1" },
})

require("plugins.ui")
require("plugins.oil")
require("plugins.fzf")
require("plugins.formatting")
require("plugins.completion")
