return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				custom_highlights = {},
			})
			vim.cmd("colorscheme catppuccin-mocha")
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

			-- Optional: integrate with LazyVim keymaps
			vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
			vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
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
		priority = 10, -- Needs to be a really low priority, to catch others plugins keybindings.
		opts = {
			-- your configuration
		},
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

			theme.header.val = {
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
			}

			theme.header.val = {
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
			}

			require("alpha").setup(theme.config)
		end,
	},
}
