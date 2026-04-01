vim.g.mapleader = " "

-- Options
require("config.options")
-- Keymaps
require("config.keymaps")
-- Terminal
require("custom.terminal")
-- Auto Session
require("custom.session")
-- Tmux navigation
require("custom.tmux-nav")
-- Blink when yanking
require("custom.yank-blink").setup()
-- Display marks 
require("custom.marks").setup()

-- Plugins
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/rose-pine/neovim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/akinsho/bufferline.nvim",
})

-- Colorscheme
vim.cmd.colorscheme("rose-pine")

-- Lualine
require("lualine").setup({
sections= { lualine_c = { { "filename", symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" }, }, }, }
})

-- Bufferline
require("bufferline").setup()

-- Oil
require("oil").setup({
  view_options = { show_hidden = true },
})
vim.keymap.set("n", "e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Fzf
require("fzf-lua").setup({
	"default",
	keymap = {
		fzf = {
			["ctrl-j"] = "down",
			["ctrl-k"] = "up",
			["down"] = "down",
			["up"] = "up",
			["right"] = "accept",
			["ctrl-l"] = "accept",
		},
	},
})
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>')
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua oldfiles<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<cr>')
