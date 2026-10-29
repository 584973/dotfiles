vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt_local.foldlevel = 99

vim.keymap.set("n", "<leader>zi", function()
  vim.lsp.foldclose("imports")
end, { buffer = true, desc = "Fold Kotlin imports" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
  .. " | setlocal tabstop< softtabstop< shiftwidth< expandtab< foldmethod< foldexpr< foldlevel<"
  .. " | silent! nunmap <buffer> <leader>zi"
