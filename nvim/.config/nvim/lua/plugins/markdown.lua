return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	keys = {
		{ "<leader>ma", ":MarkdownPreview<CR>", desc = "Markdown: start preview" },
		{ "<leader>mc", ":MarkdownPreviewStop<CR>", desc = "Markdown: stop preview" },
		{ "<leader>mt", ":MarkdownPreviewToggle<CR>", desc = "Markdown: toggle preview" },
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- use latest release, remove to use latest commit
		ft = "markdown",
		---@module 'obsidian'
		---@type obsidian.config
		opts = {
			legacy_commands = false, -- this will be removed in the next major release
			workspaces = {
				{
					name = "hobby",
					path = "~/vaulty/Hobby",
				},
				{
					name = "work",
					path = "~/vaulty/Work",
				},
			},
		},
	},
}
