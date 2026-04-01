require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofmt" },
		python = { "black" },
		javascript = { "prettier" },
	},
	format_on_save = false,
})

vim.keymap.set("n", "<leader>gf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end)
