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

-- File explorer (netrw fallback)
vim.keymap.set("n", "-", ":Ex<CR>", { desc = "Open netrw explorer" })

-- Save and quit
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>w", ":w<cr>")

-- Navigation
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")
-- Move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Auto pairs
vim.keymap.set("i", "(", "()<Left>")
vim.keymap.set("i", "[", "[]<Left>")
vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", '"', '""<Left>')
vim.keymap.set("i", "'", "''<Left>")
