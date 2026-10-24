vim.g.mapleader = " "

-- Keep bundled runtime plugins (netrw, syntax, etc.), but never load packages.
vim.opt.packpath = { vim.env.VIMRUNTIME }

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

require("config")
require("native")
require("custom")
