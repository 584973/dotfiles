vim.g.mapleader = " "

-- Keep bundled runtime plugins (netrw, syntax, etc.), but never load packages.
vim.opt.packpath = { vim.env.VIMRUNTIME }

require("options")
require("editing")
require("colorscheme")
require("buffers")
require("statusline")

require("explorer")
require("search")
require("terminal")
require("tmux-nav")
require("completion")
require("diagnostics")
require("formatting")
require("lsp")
