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
