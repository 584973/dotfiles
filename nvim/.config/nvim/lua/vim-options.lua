vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.conceallevel = 2
vim.opt.termguicolors = true
vim.g.mapleader = " "

-- Indenting lines
vim.opt.list = true
vim.opt.listchars = {
	tab = "| ",
	leadmultispace = "|   ",
}

-- vim.cmd("set clipboard=unnamedplus")

vim.diagnostic.enable()

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	float = {
		border = "rounded",
		source = true,
	},
})

-- Save and quit
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>w", ":w<cr>")

-- Navigation
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

-- Random
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
