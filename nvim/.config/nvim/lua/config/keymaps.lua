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
