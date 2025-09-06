vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "<leader>tt", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.cmd("startinsert")
	vim.api.nvim_win_set_height(0, 10)
end)

vim.keymap.set("n", "<leader>tf", function()
	vim.cmd.term()
	vim.cmd("startinsert")
end)
