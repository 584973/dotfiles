vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.conceallevel = 2
vim.opt.termguicolors = true
vim.g.mapleader = " "

-- vim.cmd("set clipboard=unnamedplus")

vim.diagnostic.enable()

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	float = {
		border = "rounded",
		source = true,
	},
})

-- Save and quit
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>w", ":w<cr>")

-- Navigation
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

-- Lsp
vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, {})

-- Bufferline
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })

-- Git
vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", {})
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})


-- Random
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Monorepo testing
vim.keymap.set("n", "<leader>t", "<cmd>RunMonorepoTest<cr>", { desc = "run tests on given project" })
vim.keymap.set(
	"n",
	"<leader>tp",
	"<cmd>RunMonorepoPlaywrightTest<cr>",
	{ desc = "run playwright tests on given project" }
)
vim.keymap.set("n", "<leader>tP", "<cmd>RunMonorepoPlaywrightUI<cr>", { desc = "opening playwright ui" })
