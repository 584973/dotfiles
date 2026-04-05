require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<C-space>"] = {}, -- disabled: tmux leader
		["<CR>"] = { "accept", "fallback" },
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	completion = {
		menu = {
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "kind", "source_name", gap = 1 },
				},
			},
		},
	},
})
