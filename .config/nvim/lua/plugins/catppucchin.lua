return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	setup,
	config = function()
		vim.cmd("colorscheme catppuccin-macchiato")
	end,
}
