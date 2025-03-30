return {
	--[[
  dir = "~/hobby/quicknote-nvim", -- local path
	name = "quicknote",
	config = function()
		require("quicknote").setup()
	end,
  --]]

	"584973/quicknote.nvim",
	config = function()
		require("quicknote").setup()
	end,

	vim.keymap.set("n", "<leader>qn", "<cmd>QuickNote<CR>", { desc = "Open QuickNote" }),
}
