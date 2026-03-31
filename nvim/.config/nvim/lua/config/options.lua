vim.g.mapleader = " "

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.conceallevel = 2
vim.opt.termguicolors = true

-- Indenting lines
vim.opt.list = true
vim.opt.listchars = {
	tab = "| ",
	leadmultispace = "|   ",
}

vim.opt.undofile = true

vim.diagnostic.enable()

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	float = {
		border = "rounded",
		source = true,
	},
})
