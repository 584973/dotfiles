return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local fzf = require("fzf-lua")

			fzf.setup({ "default" })

			-- Override vim.ui.select (replaces telescope-ui-select)
			fzf.register_ui_select()

			vim.keymap.set("n", "<leader>ff", fzf.files, {})
			vim.keymap.set("n", "<leader>fr", fzf.oldfiles, {})
			vim.keymap.set("n", "<leader>fg", fzf.live_grep, {})
			vim.keymap.set("n", "<leader>fb", fzf.buffers, {})
			vim.keymap.set("n", "<leader>fh", fzf.help_tags, {})
		end,
	},
}
