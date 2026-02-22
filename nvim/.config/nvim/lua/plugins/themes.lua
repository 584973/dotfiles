return {
	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
		enabled = true,
		config = function()
			require("vague").setup({ transparent = true})
			vim.cmd.colorscheme("vague")
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		enabled = false,
		opts = {},
		config = function()
			require("tokyonight")
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		enabled = false,
		config = function()
			vim.cmd.colorscheme("rose-pine")
		end,
	},
}
