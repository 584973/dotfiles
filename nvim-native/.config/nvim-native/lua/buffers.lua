local M = {}

vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.require'buffers'.tabline()"

function M.tabline()
  local labels = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      local selected = buf == vim.api.nvim_get_current_buf()
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
      local modified = vim.bo[buf].modified and " +" or ""
      labels[#labels + 1] = (selected and "%#TabLineSel#" or "%#TabLine#")
        .. " " .. buf .. ":" .. (name ~= "" and name or "[No Name]"):gsub("%%", "%%%%") .. modified .. " "
    end
  end
  return table.concat(labels) .. "%#TabLineFill#%T"
end

vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")
vim.keymap.set("n", "<leader>fb", ":buffer ", { desc = "Find buffers (type, then Tab)" })

return M
