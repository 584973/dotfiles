return {
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
				source_selector = {
					winbar = true,
				},
				filesystem = {
					follow_current_file = {
						enabled = true,
					},
					filtered_items = {
						visible = true,
						show_hidden_count = true,
						hide_dotfiles = false,
						hide_gitignore = false,
					},
				},
			})

			vim.api.nvim_set_keymap(
				"n",
				"<leader>e",
				":Neotree source=filesystem reveal=true toggle=true<CR> ",
				{ noremap = true, silent = true }
			)
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy", -- or "BufReadPre" if you want it early
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers", -- or "tabs"
					numbers = "none",
					close_command = "bdelete! %d",
					right_mouse_command = "bdelete! %d",
					diagnostics = "nvim_lsp",
					show_buffer_close_icons = true,
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
			require("lualine").setup({})
		end,
	},
	{
		"karb94/neoscroll.nvim",
		opts = {},
	},
	{
		"rachartier/tiny-glimmer.nvim",
		event = "VeryLazy",
		priority = 10,
		opts = {},
	},
	{
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			---@module "ibl"
			---@type ibl.config
			opts = {},
			config = function()
				require("ibl").setup()
			end,
		},
	},
	{
		"goolord/alpha-nvim",
		dependencies = { "echasnovski/mini.icons" },
		config = function()
			local theme = require("alpha.themes.theta")
			theme.file_icons.provider = "devicons"

			local headers = {
				{
					"⡟⢡⣿⣿⡿⠋⣼⡏⢂⣼⠟⠁⠀⣡⣶⣿⡿⢋⣩⣅⡀⠀⢀⣤⣶⣶⣦⡀⠈⠛⢿⣿⣦⠀⣠⣶⣦⠀⣸⣿⣿⡟⢱⣿⣿⡿⢣⣾⡇⢸⣿⡇⢢⠹⣿",
					"⠇⣾⣿⡟⠁⣼⠞⠂⡾⠃⣠⠄⠰⠛⠉⡅⢄⠈⠉⣛⠛⠿⣿⣿⣿⠛⠉⠀⠀⠀⠀⠙⣿⣧⠈⠉⠁⠀⣿⣿⣿⠁⣿⣿⡿⢡⣿⣿⠇⣾⣿⡇⣼⢠⠘",
					"⠀⣿⣿⠁⢰⠿⠀⣸⠇⠘⠋⡀⠀⠁⠀⠀⠀⠀⠀⠀⠈⠁⠒⠬⢉⠻⠶⡄⠀⠀⠀⠀⢸⣿⣧⠀⠀⠀⢿⣿⣿⣠⣿⣿⢃⣿⣿⣿⢸⣿⣿⠇⣿⢳⡆",
					"⣇⢻⣿⠂⡀⠀⠁⠛⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⣄⠀⠀⠀⠀⣼⣿⣿⠀⢾⡇⢸⡿⣿⣿⣿⣿⠀⢿⡿⢃⣿⣿⡏⣸⡟⣸⠀",
					"⣿⡌⢿⣶⣷⣈⣐⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠁⠠⠀⠺⣿⣿⡿⠀⠀⠀⠸⡿⢿⣿⣿⣿⣄⣠⣴⣿⣿⠟⣴⡟⣰⡟⢰",
					"⣿⣷⣌⢻⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣷⣦⣄⠀⠀⠀⠀⠀⠀⠂⠈⠛⢡⣾⣦⠀⠀⠩⠍⢚⣿⣿⣿⣿⣿⣿⣥⣾⠏⣴⡿⢡⣿",
					"⣿⣿⣿⣧⡙⠻⠐⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⠆⠀⣴⣶⣶⡀⠀⠉⠉⠀⠀⠀⠈⢐⣄⣻⣿⣿⣿⣿⣿⣡⣾⡟⣡⣿⣿",
					"⣿⣿⣿⣿⣿⣶⡈⠀⠀⠀⠀⠀⢀⣼⣿⡿⠋⣉⣉⣹⠟⠉⠙⠻⣿⣿⣿⢀⣠⣄⡈⠹⣿⣷⠀⠀⠀⣰⢂⠢⠠⠿⠿⠉⠃⢋⠛⠋⢹⠿⢋⣴⣿⣿⣿",
					"⣿⣿⣿⣿⣿⣿⣿⡦⠄⠀⢤⣤⡈⠻⠟⢀⣾⣿⣿⣿⣷⠠⣶⣿⣿⠿⣿⣿⣿⡿⠿⠄⣈⣡⣧⠀⠀⢻⡘⢿⣦⠑⠈⠀⠀⠀⠈⢠⣤⣾⣿⣿⣿⣿⣿",
					"⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⣸⣿⣷⠘⠟⠛⢛⣿⣷⣌⠛⠁⠈⠛⢡⣾⣿⣿⣿⣥⣀⢀⡀⠉⣩⡀⠀⠀⣤⣤⣤⣀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿",
					"⣿⣿⣿⣿⣿⢉⠀⠀⠀⢠⣿⣿⣿⣇⡘⢰⣿⣿⣿⣿⡇⢠⣈⠁⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠹⣿⣿⣿⣿⡄⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿",
					"⣿⣿⣿⣿⣿⠀⠈⠗⣀⡘⠋⠋⠉⣉⣙⠒⢤⡙⠻⣿⡇⣾⣿⠂⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠈⢉⠹⠿⠃⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
					"⣿⣿⣿⣿⣿⣦⡀⢰⣿⣇⣀⣽⠈⢿⡿⢿⣶⣌⡓⢶⣄⣙⠻⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠋⠀⠀⠀⢀⣠⣴⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠘⠿⢂⠀⠀⢀⠀⠬⠅⠂⡀⢀⡀⠐⢒⡂⠉⠛⢶⣌⠢⡀⠀⢻⡧⠀⠀⠘⣛⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
				},

				{
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁⢈⣒⠲⠾⠈⠻⢸⠿⢛⣉⡙⢿⣿⣿⣿⣿⣿⣯⢻⣿⠞⣼⣿⣿⣿⣷⣾⣿⣿⡟⣡⠈⠿⠿⠿⢿⣿⣿⠿⠀⠴⠀⠇⠘⣾⡇⢿⣿⣿⣿⣦⠀",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡦⠙⣥⡀⣿⣧⡴⠎⣁⡙⠿⣿⣿⣿⣿⣿⣿⣿⡈⣯⢰⠘⣿⡿⠿⠟⠛⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡇⡒⠀⠀⡄⡿⠁⢚⣿⣿⣿⣿⡇",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⢸⣧⢹⣯⣴⡿⠿⠿⠶⠬⠍⠙⠛⠛⠛⠿⠇⣿⠨⡑⠈⠀⠀⠀⢀⡤⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⡇⠇⢰⡆⢰⠃⠀⢰⣿⣿⣿⣿⢃",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢀⡙⠌⠃⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⡇⠁⠀⠀⠁⠀⠀⢺⣿⣿⣿⡿⣸",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠘⠆⠀⠀⠀⠛⠁⠀⠀⠀⠀⠀⠀⠀⢀⣶⠸⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⠁⠀⠀⠀⠀⠐⢦⡍⣹⣿⣿⣇⣿",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢠⠢⡄⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⡀⢿⣿⣿⣿⣿⣷⣦⣤⡤⠄⢀⣂⣀⣙⡛⠿⣿⣿⣿⡀⠀⠀⢠⡘⣦⡱⣶⣿⣿⡟⣸⣿",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⢸⣧⡄⠀⠈⢶⣶⣶⣶⣶⣶⣶⣿⣿⣿⣿⡇⢸⣿⡿⢿⣿⡿⢛⣩⣶⣿⣿⣿⣿⣿⣿⣶⣌⢻⣿⡇⠀⠀⡆⠱⡌⣣⣿⣿⣿⣇⣿⣿",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠁⠀⢸⣿⣿⡌⠂⠀⢻⣿⡿⢛⣫⣭⣭⣭⣭⣿⣓⣌⣛⣥⣬⣵⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡘⠁⡄⠀⡇⡆⠀⣽⣿⣿⣿⣍⠻⣿",
					"⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⢸⣿⣿⣄⣓⠀⠀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡿⡿⠟⣿⡿⢿⣿⣿⣿⣿⣶⣤⣀⣁⣁⠸⢛⣿⣿⣿⠿⢓⣸",
					"⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡗⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠉⠉⠉⠉⠻⠙⢷⢀⢌⠂⠻⣌⠂⠢⠙⢟⡻⣿⣿⣿⠿⠋⠀⣾⣿⣿⣷⣦⡍⠹",
					"⣿⣿⣿⡿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠀⣼⣿⣿⣿⣿⣿⣿⡿⣿⡿⠁⠠⠤⠶⣒⣋⣥⣶⠷⢀⣤⠤⣌⣀⣉⠓⠀⠀⠀⠀⠀⡄⠀⠀⠈⢼⣿⣿⡿⠟⠋⠀⠀",
					"⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⠏⣴⣿⣿⠋⢹⣏⠇⠻⠇⠟⣁⡐⠒⠛⠛⢛⣋⣩⣤⠶⠛⣡⣴⣿⣿⣿⠏⡀⡀⢸⠀⠀⠁⠀⠀⢐⣿⠟⠁⠀⠀⠀⠀⠀",
					"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⠛⢛⣋⣥⠞⡫⢐⠁⠂⡸⠃⠀⠂⠠⣾⣿⣍⠛⠛⣛⣛⣭⣭⣴⣶⣾⣿⣿⣿⡿⠃⠀⠃⠇⠈⠀⢀⠀⠰⢀⣾⡇⠀⠀⠀⠀⢀⣬⣶",
					"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⣦⣬⣀⣈⠀⠕⢚⣈⠀⢴⡾⠁⣦⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠟⠛⠉⠀⢠⠀⠀⠀⠀⢰⢸⠀⠀⣸⣿⣿⣶⣤⠀⢠⣾⣿⣿",
				},
			}
			theme.header.val = headers[math.random(#headers)]
			require("alpha").setup(theme.config)
		end,
	},
}
