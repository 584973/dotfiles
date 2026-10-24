local M = {}

function M.format()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local prettier = { "prettier", "--stdin-filepath", name }
  local formatters = {
    lua = { "stylua", "--search-parent-directories", "--stdin-filepath", name, "-" },
    go = { "gofmt" },
    python = { "black", "--stdin-filename", name, "-" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    html = prettier,
  }
  local command = formatters[vim.bo[buf].filetype]
  if not command or vim.fn.executable(command[1]) == 0 then
    local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })
    if #clients > 0 then
      vim.lsp.buf.format({ bufnr = buf, async = true })
    else
      vim.notify("No formatter or formatting language server available", vim.log.levels.WARN)
    end
    return
  end
  if name == "" then
    vim.notify("Save the buffer before formatting", vim.log.levels.WARN)
    return
  end

  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  if vim.bo[buf].endofline then
    input = input .. "\n"
  end
  local ok, err = pcall(vim.system, command, { stdin = input, text = true, timeout = 10000 },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        vim.notify(result.stderr and result.stderr ~= "" and result.stderr or "Formatting failed", vim.log.levels.WARN)
        return
      end
      if not vim.api.nvim_buf_is_loaded(buf) then
        return
      end
      if vim.api.nvim_buf_get_changedtick(buf) ~= tick then
        vim.notify("Buffer changed while formatting; result discarded", vim.log.levels.WARN)
        return
      end
      local lines = vim.split(result.stdout, "\n", { plain = true })
      local endofline = lines[#lines] == ""
      if endofline then
        table.remove(lines)
      end
      local views = {}
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].endofline = endofline
      for win, view in pairs(views) do
        vim.api.nvim_win_call(win, function() vim.fn.winrestview(view) end)
      end
    end))
  if not ok then
    vim.notify(tostring(err), vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<leader>gf", M.format, { desc = "Format buffer" })

return M
