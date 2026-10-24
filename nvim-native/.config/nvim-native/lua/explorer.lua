-- netrw ships with Neovim; hidden files are visible by default.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_hide = 0

vim.keymap.set("n", "e", function()
  local name = vim.api.nvim_buf_get_name(0)
  local directory = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
  vim.cmd.Explore(vim.fn.fnameescape(directory))
end, { desc = "Open parent directory" })
