return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons"},
	config = function()
		options = {
			theme = "dracula",
		}
		require("lualine").setup{
      options = options,
    }
	end,
}

