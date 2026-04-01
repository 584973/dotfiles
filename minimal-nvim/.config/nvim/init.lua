vim.g.mapleader = " "

-- Options
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
vim.opt.list = true
vim.opt.listchars = {
  tab = "| ",
  leadmultispace = "|   ",
}

-- Plugins
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/rose-pine/neovim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/ibhagwan/fzf-lua",
})

-- Colorscheme
vim.cmd.colorscheme("rose-pine")

-- Auto pairs
vim.keymap.set("i", "(", "()<Left>")
vim.keymap.set("i", "[", "[]<Left>")
vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", '"', '""<Left>')
vim.keymap.set("i", "'", "''<Left>")

-- Save and quit
vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")

-- Buffers
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")

-- Move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Auto Session
require("session")

-- Tmux navigation
require("tmux-nav")

-- Terminal
require("terminal")

-- Lualine
require("lualine").setup({
sections= { lualine_c = { { "filename", symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" }, }, }, }
})

-- Oil
require("oil").setup({
  view_options = { show_hidden = true },
})
vim.keymap.set("n", "e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Fzf
-- require("fzf-lua")
-- vim.keymap.set("n", "<leader>ff", fzf.files, {})
-- vim.keymap.set("n", "<leader>fr", fzf.oldfiles, {})
-- vim.keymap.set("n", "<leader>fg", fzf.live_grep, {})
-- vim.keymap.set("n", "<leader>fb", fzf.buffers, {})
-- vim.keymap.set("n", "<leader>fh", fzf.help_tags, {})
--
