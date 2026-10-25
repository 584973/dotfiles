local stdin = false
local namespace = vim.api.nvim_create_namespace("dashboard")

local function clip(text, width)
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  while vim.fn.strdisplaywidth(text .. "…") > width and text ~= "" do
    text = vim.fn.strcharpart(text, 0, vim.fn.strchars(text) - 1)
  end
  return width > 0 and text .. "…" or ""
end

local function render(buf, win, cwd, files, prefix)
  local win_width = vim.api.nvim_win_get_width(win)
  local width = math.max(1, math.min(60, win_width - 4))
  local lines, highlights, items = {}, {}, {}
  local function row(chunks, centered, key)
    local text, spans = "", {}
    for _, chunk in ipairs(chunks) do
      local part = clip(chunk[1], width - vim.fn.strdisplaywidth(text))
      spans[#spans + 1] = { #text, #text + #part, chunk[2] }
      text = text .. part
    end
    local indent = math.max(0, math.floor((win_width - (centered and vim.fn.strdisplaywidth(text) or width)) / 2))
    lines[#lines + 1] = string.rep(" ", indent) .. text
    if key then
      items[#items + 1] = { line = #lines, column = indent + math.min(2, #text), key = key }
    end
    for _, span in ipairs(spans) do
      if span[2] > span[1] then
        highlights[#highlights + 1] = { #lines - 1, indent + span[1], indent + span[2], span[3] }
      end
    end
  end

  local logo = {
    "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██║   ██║██║████╗ ████║",
    "██╔██╗ ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
  }
  local colors = { "Function", "Function", "Directory", "Directory", "Title", "Comment" }
  for i, line in ipairs(logo) do
    row({ { line, colors[i] } }, true)
  end
  row({})
  row({ { vim.fs.basename(cwd), "Title" } }, true)
  row({ { vim.fn.fnamemodify(cwd, ":~"), "Comment" } }, true)
  row({})
  row({ { "RECENT FILES", "Directory" } })
  row({ { string.rep("─", width), "Comment" } })
  for i, file in ipairs(files) do
    local relative = file:sub(#prefix + 1)
    local directory = relative:match("^(.*)/")
    row({
      { "  [" .. i .. "]  ", "Number" },
      { directory and directory .. "/" or "", "Comment" },
      { vim.fs.basename(file), "Normal" },
    }, false, tostring(i))
  end
  if #files == 0 then
    row({ { "No recent files here yet.", "Comment" } })
  end
  row({})
  row({ { "  [n]  ", "Special" }, { "Create file", "Normal" } }, false, "n")
  row({ { "  [f]  ", "Special" }, { "Find file", "Normal" } }, false, "f")
  row({ { "  [q]  ", "Special" }, { "Quit", "Normal" } }, false, "q")
  row({})
  row({ { "↑/↓ or j/k to move · Enter to select", "Comment" } }, true)

  local top = math.max(0, math.floor((vim.api.nvim_win_get_height(win) - #lines) / 2))
  for _ = 1, top do
    table.insert(lines, 1, "")
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
  for _, mark in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(buf, namespace, top + mark[1], mark[2], {
      end_col = mark[3],
      hl_group = mark[4],
    })
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  for _, item in ipairs(items) do
    item.line = item.line + top
  end
  return items
end

vim.api.nvim_create_autocmd("StdinReadPre", {
  once = true,
  callback = function()
    stdin = true
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if stdin or vim.fn.argc() > 0 or vim.bo.modified or vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) ~= "" then
      return
    end

    local cwd = vim.fs.normalize(vim.uv.fs_realpath(vim.fn.getcwd()))
    local prefix = cwd:sub(-1) == "/" and cwd or cwd .. "/"
    local files, seen = {}, {}
    for _, file in ipairs(vim.v.oldfiles) do
      local path = vim.uv.fs_realpath(file)
      if path then
        path = vim.fs.normalize(path)
      end
      if path and vim.startswith(path, prefix) and not seen[path] and vim.fn.filereadable(path) == 1 then
        files[#files + 1] = path
        seen[path] = true
        if #files == 5 then
          break
        end
      end
    end

    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].buflisted = false
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "dashboard"

    local win = vim.api.nvim_get_current_win()
    local options = {
      number = false,
      relativenumber = false,
      cursorline = true,
      cursorlineopt = "line",
      list = false,
      wrap = false,
      scrolloff = 0,
      signcolumn = "no",
      foldcolumn = "0",
      colorcolumn = "",
      fillchars = "eob: ",
    }
    local saved = {}
    for option, value in pairs(options) do
      saved[option] = vim.wo[win][option]
      vim.wo[win][option] = value
    end
    vim.api.nvim_create_autocmd("BufWinLeave", {
      buffer = buf,
      once = true,
      callback = function()
        if vim.api.nvim_win_is_valid(win) then
          for option, value in pairs(saved) do
            vim.wo[win][option] = value
          end
        end
      end,
    })

    local items, selected = {}, 1
    local function select(index)
      selected = (index - 1) % #items + 1
      local item = items[selected]
      vim.api.nvim_win_set_cursor(win, { item.line, item.column })
    end
    local function redraw()
      items = render(buf, win, cwd, files, prefix)
      select(selected)
    end
    redraw()
    local resize = vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
      callback = function()
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
          redraw()
        end
      end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
      buffer = buf,
      once = true,
      callback = function()
        vim.api.nvim_del_autocmd(resize)
      end,
    })

    local actions = {}
    local function action(key, callback, desc)
      actions[key] = callback
      vim.keymap.set("n", key, callback, { buffer = buf, silent = true, desc = desc })
    end
    for i, file in ipairs(files) do
      action(tostring(i), function()
        vim.cmd.edit({ args = { file } })
      end, "Open " .. file:sub(#prefix + 1))
    end
    action("n", function()
      vim.ui.input({ prompt = "New file: ", completion = "file" }, function(name)
        if name and name:match("%S") then
          vim.cmd.edit({ args = { name } })
        end
      end)
    end, "Create file")
    action("f", function()
      require("fzf-lua").files({ cwd = cwd })
    end, "Find file")
    action("q", function()
      vim.cmd.quitall()
    end, "Quit Neovim")

    for _, key in ipairs({ "j", "<Down>" }) do
      vim.keymap.set("n", key, function()
        select(selected + 1)
      end, { buffer = buf, silent = true, desc = "Next option" })
    end
    for _, key in ipairs({ "k", "<Up>" }) do
      vim.keymap.set("n", key, function()
        select(selected - 1)
      end, { buffer = buf, silent = true, desc = "Previous option" })
    end
    vim.keymap.set("n", "<CR>", function()
      actions[items[selected].key]()
    end, { buffer = buf, silent = true, desc = "Select option" })
  end,
})
