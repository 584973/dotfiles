vim.g.mapleader = " "

vim.diagnostic.config({
	virtual_text = true, -- show errors inline
	signs = true, -- show signs in the gutter
	underline = true, -- underline problematic code
	update_in_insert = false, -- don't update while typing
})

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
-- Lsp
require("lsp")

-- Plugins
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/stevearc/conform.nvim",
})

-- Colorscheme
vim.cmd.colorscheme("rose-pine")

-- Lsp
vim.lsp.enable('lua_ls')

-- Lualine
require("lualine").setup({
	sections = {
		lualine_c = { { "filename", symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } } },
	},
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
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>")

-- Formatting
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofmt" },
		python = { "black" },
		javascript = { "prettier" },
	},
	format_on_save = false,
})

vim.keymap.set("n", "<leader>gf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end)
