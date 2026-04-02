return {
	{
		"rose-pine/neovim",
		config = function()
			require("rose-pine").setup({ styles = { transparency = true } })
			vim.cmd.colorscheme("rose-pine")
		end,
	},
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				view_options = { show_hidden = true },
				win_options = {
					winbar = "%{v:lua.require('oil').get_current_dir()}",
				},
			})
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				popup_border_style = "rounded",
				enable_git_status = true,
				enable_diagnostics = true,
				source_selector = {
					winbar = true,
				},
				window = {
					position = "left",
					width = 30,
					mappings = {
						["l"] = "open",
						["<Right>"] = "open",
						["h"] = "close_node",
						["<Left>"] = "close_node",
					},
				},
				filesystem = {
					hijack_netrw_behavior = "open_default",
					follow_current_file = {
						enabled = true,
						leave_dirs_open = false,
					},
					use_libuv_file_watcher = true,
					filtered_items = {
						visible = true,
						hide_dotfiles = false,
						hide_gitignore = false,
						hide_hidden = false,
					},
				},
			})

			vim.keymap.set("n", "<leader>e", function()
				if vim.bo.filetype == "neo-tree" then
					vim.cmd("wincmd p")
				else
					require("neo-tree.command").execute({
						toggle = true,
						source = "filesystem",
						position = "float",
					})
				end
			end, { desc = "Explorer (Neo-tree)" })

			vim.keymap.set("n", "<leader>E", function()
				require("neo-tree.command").execute({
					action = "focus",
					source = "filesystem",
					reveal = true,
				})
			end, { desc = "Reveal file in Explorer" })
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					diagnostics = "nvim_lsp",
					show_close_icon = false,
					separator_style = "thin",
					offsets = {
						{
							filetype = "neo-tree",
							text = "File Explorer",
							highlight = "Directory",
							text_align = "left",
						},
					},
				},
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				sections = {
					lualine_c = {
						{
							"filename",
							symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
						},
					},
				},
			})
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
		},
	},
}
