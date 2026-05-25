local fzf = require("fzf-lua")

fzf.setup({
	"default",
	keymap = {
		fzf = {
			["ctrl-j"] = "down",
			["ctrl-k"] = "up",
			["right"] = "accept",
			["ctrl-l"] = "accept",
		},
	},
})

fzf.register_ui_select()

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>")
vim.keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<cr>")
