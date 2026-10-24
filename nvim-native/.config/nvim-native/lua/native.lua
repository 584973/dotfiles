local M = {}

-- Built-in colorscheme, with the terminal background showing through.
vim.cmd.colorscheme("catppuccin")
for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }) do
  vim.api.nvim_set_hl(0, group, { bg = "NONE" })
end

vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.statusline = " [%{toupper(mode())}] %f %h%m%r%=%y  %l:%c  %p%% "
vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.require'native'.tabline()"

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

-- netrw ships with Neovim; hidden files are visible by default.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_hide = 0
vim.keymap.set("n", "e", function()
  local name = vim.api.nvim_buf_get_name(0)
  local directory = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
  vim.cmd.Explore(vim.fn.fnameescape(directory))
end, { desc = "Open parent directory" })

vim.opt.wildmode = "noselect:full"
vim.opt.wildoptions:append("fuzzy")
vim.opt.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/.venv/*" })
vim.opt.findfunc = "v:lua.require'native'.find"

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
vim.keymap.set("n", "<leader>fb", ":buffer ", { desc = "Find buffers (type, then Tab)" })
vim.keymap.set("n", "<leader>fh", ":help ", { desc = "Find help (type, then Tab)" })
vim.keymap.set("n", "<leader>fm", "<cmd>marks<cr>", { desc = "List marks" })

return M
