return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local options = {
			theme = "auto",
		}
		require("lualine").setup({
			options = options,
		})
	end,
}
