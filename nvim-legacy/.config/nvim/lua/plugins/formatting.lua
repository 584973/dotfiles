return {
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = false,

			formatters_by_ft = {
				go = { "goimports", "gofumpt" },
				python = { "isort", "black" },
				typescript = { "prettier" },
				javascript = { "prettier" },
				java = { "google-java-format" },
				lua = { "stylua" },
				kotlin = { "ktlint" },
			},
		},
		keys = {
			{
				"<leader>gf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format buffer",
			},
		},
	},
}
