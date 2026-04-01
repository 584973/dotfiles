vim.g.mapleader = " "

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
})

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end })

require("config.options")
require("config.keymaps")
require("custom.terminal")
require("custom.session")
require("custom.tmux-nav")

require("plugins")
require("lsp")
