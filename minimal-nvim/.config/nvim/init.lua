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
})

-- Colorscheme
vim.cmd.colorscheme("rose-pine")


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
