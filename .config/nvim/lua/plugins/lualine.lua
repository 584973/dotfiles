return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons"},
	config = function()
		options = {
			theme = "catppuccin-mocha",
		}
		require("lualine").setup{
      options = options,
    }
	end,
}

