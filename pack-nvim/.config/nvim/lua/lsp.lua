vim.lsp.config("angularls", {
	cmd = { "ngserver", "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" },
	filetypes = { "html", "typescript", "htmlangular" },
	root_markers = { "angular.json" },
	on_new_config = function(new_config, new_root_dir)
		local node_modules = new_root_dir .. "/node_modules"
		new_config.cmd = {
			"ngserver",
			"--stdio",
			"--tsProbeLocations", node_modules,
			"--ngProbeLocations", node_modules,
		}
	end,
})

vim.lsp.enable({ "lua_ls", "gopls", "pyright", "ts_ls", "angularls" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, {})
