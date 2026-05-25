require("lint").linters_by_ft = {
	lua = { "luacheck" },
	go = { "golangcilint" },
	python = { "ruff" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
