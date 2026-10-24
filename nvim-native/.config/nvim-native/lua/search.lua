local M = {}

vim.opt.wildmode = "noselect:full"
vim.opt.wildoptions:append("fuzzy")
vim.opt.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/.venv/*" })
vim.opt.findfunc = "v:lua.require'search'.find"

-- Use native fuzzy matching with :find's native completion menu.
function M.find(pattern, _)
  local files = vim.fn.glob("**/*", false, true)
  files = vim.tbl_filter(function(file)
    return vim.fn.filereadable(file) == 1
  end, files)
  return pattern == "" and files or vim.fn.matchfuzzy(files, pattern)
end

function M.grep()
  vim.ui.input({ prompt = "Search pattern (Vim regex): " }, function(pattern)
    if not pattern or pattern == "" then
      return
    end
    local ok, err = pcall(vim.cmd.vimgrep, {
      args = { "/" .. vim.fn.escape(pattern, "/") .. "/gj", "**/*" },
    })
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
      return
    end
    vim.cmd.copen()
  end)
end

vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find files (type, then Tab)" })
vim.keymap.set("n", "<leader>fr", "<cmd>browse oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fg", M.grep, { desc = "Search files into quickfix" })
vim.keymap.set("n", "<leader>fh", ":help ", { desc = "Find help (type, then Tab)" })
vim.keymap.set("n", "<leader>fm", "<cmd>marks<cr>", { desc = "List marks" })

return M
