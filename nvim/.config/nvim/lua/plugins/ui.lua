-- Colorscheme
require("tokyonight").setup({
	transparent = true,
	styles = { floats = "transparent", sidebars = "transparent" },
})
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

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("snacks").setup({
	picker = {
		enabled = true,
		sources = {
			explorer = {
				hidden = true,
				auto_close = true,
				jump = { close = true },
				layout = { preset = "sidebar", preview = false },
			},
		},
	},
})

vim.keymap.set("n", "e", function()
	Snacks.picker.explorer()
end, { desc = "Open file explorer" })
