return {
	-- Language servers
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"jdtls",
					"gopls",
					"lua_ls",
					"ts_ls",
					"tailwindcss",
					"jsonls",
					"eslint",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.eslint.setup({
				capabilities = capabilities,
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
				root_dir = util.root_pattern(".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", "package.json", ".git"),
			})
			lspconfig.angularls.setup({
				capabilities = capabilities,
				on_attach = function(client)
					client.server_capabilities.diagnosticProvider = nil
					client.server_capabilities.documentFormattingProvider = false
				end,
				filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
				root_dir = util.root_pattern("angular.json", "project.json"),
			})
			lspconfig.java_language_server.setup({
				capabilities = capabilities,
			})
			lspconfig.gopls.setup({
				capabilities = capabilities,
			})
			lspconfig.pylsp.setup({
				capabilities = capabilities,
			})
			lspconfig.marksman.setup({
				capabilities = capabilities,
			})
			lspconfig.jdtls.setup({
				capabilities = capabilities,
			})
			lspconfig.yamlls.setup({
				capabilities = capabilities,
			})
			lspconfig.gdscript.setup({
				capabilities = capabilities,
			})
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
			})
			lspconfig.jsonls.setup({
				capabilities = capabilities,
			})
			lspconfig.dockerls.setup({
				capabilities = capabilities,
			})

			vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})

			vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, bufopts)
			vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)
		end,
	},
	-- Formatting
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
	-- Linting
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				python = { "flake8" },
				go = { "golangci_lint" },
			}

			-- Auto-lint on save
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
