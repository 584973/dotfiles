-- netrw ships with Neovim; hidden files are visible by default.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_hide = 0
vim.g.netrw_alto = 1
vim.g.netrw_altv = 1

local namespace = vim.api.nvim_create_namespace("explorer-hints")
local function hints(items)
  local chunks = { { "  ", "Normal" } }
  for i, item in ipairs(items) do
    chunks[#chunks + 1] = { item[1], "Special" }
    chunks[#chunks + 1] = { " " .. item[2] .. (i < #items and "   " or ""), "Comment" }
  end
  return chunks
end

local guide = {
  { { "  EXPLORE", "Title" } },
  hints({ { "Enter", "Open" }, { "-", "Parent" }, { "%", "New file" }, { "d", "New folder" } }),
  hints({ { "R", "Rename" }, { "D", "Delete" }, { "o", "Split down" }, { "v", "Split right" } }),
  hints({ { "gh", "Hidden" }, { "F1", "Help" } }),
  { { "", "Normal" } },
}

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  callback = function(event)
    if vim.bo[event.buf].filetype ~= "netrw" then
      return
    end
    -- Virtual lines keep hints out of netrw's file entries and cursor movement.
    vim.api.nvim_buf_set_extmark(event.buf, namespace, 0, 0, {
      id = 1,
      right_gravity = false,
      virt_lines = guide,
      virt_lines_above = true,
      virt_lines_leftcol = true,
    })
    -- netrw restores its view after FileType; reveal the guide after it finishes.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end
      for _, win in ipairs(vim.fn.win_findbuf(event.buf)) do
        vim.api.nvim_win_call(win, function()
          local view = vim.fn.winsaveview()
          if view.topline == 1 then
            view.topfill = #guide
            vim.fn.winrestview(view)
          end
        end)
      end
    end)
  end,
})

vim.keymap.set("n", "e", function()
  local name = vim.api.nvim_buf_get_name(0)
  local directory = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
  vim.cmd.Explore(vim.fn.fnameescape(directory))
end, { desc = "Open parent directory" })
