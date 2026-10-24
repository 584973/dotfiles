-- Built-in colorscheme, with the terminal background showing through.
vim.cmd.colorscheme("catppuccin")
for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }) do
  vim.api.nvim_set_hl(0, group, { bg = "NONE" })
end
