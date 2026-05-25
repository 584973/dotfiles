-- Colorscheme
require("tokyonight").setup({ transparent = true })
vim.cmd.colorscheme("tokyonight")

-- Tabs
require("bufferline").setup()

-- Statusbar
require("lualine").setup({
	sections = {
		lualine_c = { { "filename", symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } } },
	},
})

-- Filetree
require("oil").setup({
	view_options = { show_hidden = true },
	win_options = {
		winbar = "%{v:lua.require('oil').get_current_dir()}",
	},
})

vim.keymap.set("n", "e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
