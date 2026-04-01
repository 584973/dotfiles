-- Colorscheme
require("rose-pine").setup({ styles = { transparency = true } })
vim.cmd.colorscheme("rose-pine")

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
})

vim.keymap.set("n", "e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
