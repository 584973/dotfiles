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
vim.opt.undofile = true

-- Indenting lines
vim.opt.list = true
vim.opt.listchars = {
	tab = "| ",
	leadmultispace = "|   ",
}

-- Auto pairs
vim.keymap.set("i", "(", "()<Left>")
vim.keymap.set("i", "[", "[]<Left>")
vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", '"', '""<Left>')
vim.keymap.set("i", "'", "''<Left>")


vim.pack.add({
'https://github.com/neovim/nvim-lspconfig',
'https://github.com/stevearc/oil.nvim',
'https://github.com/rose-pine/neovim',
})

vim.cmd.colorscheme('rose-pine')

require("oil").setup()
vim.keymap.set("n", "e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

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

-- Tmux nav
local function navigate(dir)
	local nr = vim.fn.winnr()
	vim.cmd("wincmd " .. dir)
	if vim.fn.winnr() == nr and vim.env.TMUX then
		local map = { h = "L", j = "D", k = "U", l = "R" }
		vim.fn.system("tmux select-pane -" .. map[dir])
	end
end

vim.keymap.set("n", "<C-h>", function() navigate("h") end)
vim.keymap.set("n", "<C-j>", function() navigate("j") end)
vim.keymap.set("n", "<C-k>", function() navigate("k") end)
vim.keymap.set("n", "<C-l>", function() navigate("l") end)

