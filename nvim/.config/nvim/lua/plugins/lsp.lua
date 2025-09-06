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
			local util = require("lspconfig.util")

			vim.lsp.config("eslint", {
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
				root_dir = util.root_pattern(".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", "package.json", ".git"),
			})

			vim.lsp.enable({
				"ts_ls",
				"gopls",
				"lua_ls",
				"java_language_server",
				"pylsp",
				"marksman",
				"jdtls",
				"yamlls",
				"tailwindcss",
				"jsonls",
				"dockerls",
				"kotlin_lsp",
				"angularls",
				"eslint",
			})
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
				go = { "golangcilint" },
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
