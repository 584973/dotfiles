vim.g.mapleader = " "

vim.diagnostic.config({
	virtual_text = true, -- show errors inline
	signs = true, -- show signs in the gutter
	underline = true, -- underline problematic code
	update_in_insert = false, -- don't update while typing
})

require("config.options")
require("config.keymaps")
require("custom.terminal")
require("custom.session")
require("custom.tmux-nav")
require("custom.yank-blink").setup()
require("custom.marks").setup()

require("plugins")
require("lsp")
