local directory = vim.fn.tempname()
local cwd = vim.fn.getcwd()
local input, feedkeys, quitall = vim.ui.input, vim.api.nvim_feedkeys, vim.cmd.quitall
local case = assert(vim.env.NATIVE_DASHBOARD_CASE)

local ok, err = xpcall(function()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  local project = directory .. "/project"
  vim.fn.mkdir(project .. "/nested", "p")
  local files = {}
  for i, name in ipairs({
    "first file.txt",
    "nested/日本語.txt",
    "third.txt",
    "fourth.txt",
    "fifth.txt",
    "sixth.txt",
  }) do
    files[i] = project .. "/" .. name
    vim.fn.writefile({ "fixture" }, files[i])
  end
  local outside = directory .. "/outside.txt"
  vim.fn.writefile({ "outside" }, outside)
  vim.cmd.cd(project)
  vim.v.oldfiles = {
    outside,
    project .. "/missing.txt",
    project .. "/nested",
    files[1],
    files[1],
    files[2],
    files[3],
    files[4],
    files[5],
    files[6],
  }
  if case == "empty" then
    vim.v.oldfiles = { outside }
  elseif case == "argument" then
    vim.cmd.argadd({ args = { files[1] } })
  elseif case == "modified" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved text" })
  elseif case == "named" then
    vim.cmd.edit({ args = { files[1] } })
  elseif case == "stdin" then
    vim.api.nvim_exec_autocmds("StdinReadPre", {})
  end
  local buf = vim.api.nvim_get_current_buf()
  local original = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local saved = {}
  for _, key in ipairs({
    "number",
    "relativenumber",
    "cursorline",
    "cursorlineopt",
    "list",
    "wrap",
    "scrolloff",
    "signcolumn",
    "foldcolumn",
    "colorcolumn",
    "fillchars",
  }) do
    saved[key] = vim.wo[key]
  end
  vim.api.nvim_exec_autocmds("VimEnter", {})
  if case == "argument" or case == "modified" or case == "named" or case == "stdin" then
    assert(vim.bo.filetype ~= "dashboard")
    assert(vim.deep_equal(original, vim.api.nvim_buf_get_lines(buf, 0, -1, false)))
    return
  end

  assert(vim.bo.filetype == "dashboard")
  assert(vim.bo.buftype == "nofile" and not vim.bo.buflisted and not vim.bo.modifiable and not vim.bo.modified)
  local marks = vim.api.nvim_buf_get_extmarks(buf, vim.api.nvim_get_namespaces().dashboard, 0, -1, {})
  assert(#marks >= 15)
  local lines = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  assert(
    lines:find(
      "█   █  █  ███ ███ █   █ ███     █   █ █   █ ███ █   █",
      1,
      true
    )
  )
  assert(lines:find("[q]  Quit", 1, true))
  assert(not lines:find("outside.txt", 1, true))
  assert(not lines:find("missing.txt", 1, true))
  assert(not lines:find("sixth.txt", 1, true))
  assert(vim.fn.maparg("6", "n") == "")
  local function press(key)
    local mapping = vim.fn.maparg(key, "n", false, true)
    assert(type(mapping.callback) == "function", "missing mapping: " .. key)
    mapping.callback()
  end
  local function selected(key)
    assert(vim.api.nvim_get_current_line():find("[" .. key .. "]", 1, true), "wrong selection: " .. key)
  end
  local function restored()
    assert(not vim.api.nvim_buf_is_valid(buf))
    for key, value in pairs(saved) do
      assert(vim.wo[key] == value, "option not restored: " .. key)
    end
    assert(vim.fn.maparg("<CR>", "n") == "", "dashboard mapping leaked")
    vim.api.nvim_exec_autocmds("VimResized", {})
  end
  if case == "empty" then
    assert(lines:find("No recent files here yet.", 1, true))
    assert(vim.fn.maparg("1", "n") == "")
    selected("n")
    press("j")
    selected("f")
    press("j")
    selected("q")
    press("j")
    selected("n")
    return
  end
  selected("1")
  for i = 1, 5 do
    assert(lines:find("[" .. i .. "]", 1, true))
  end

  if case == "layout" then
    press("k")
    selected("q")
    press("<Up>")
    selected("f")
    press("<Up>")
    selected("n")
    press("j")
    selected("f")
    press("<Down>")
    selected("q")
    press("<Down>")
    selected("1")
    for i, columns in ipairs({ 120, 40, 20, 80 }) do
      press("j")
      vim.o.columns = columns
      vim.api.nvim_exec_autocmds("VimResized", {})
      selected(tostring(i + 1))
      for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        assert(vim.fn.strdisplaywidth(line) <= vim.api.nvim_win_get_width(0), "line overflow")
      end
      assert(not vim.bo.modified and not vim.bo.modifiable)
    end
  elseif case:match("^open[1-5]$") or case:match("^shortcut[1-5]$") then
    local index = tonumber(case:sub(-1))
    if case:match("^open") then
      for _ = 2, index do
        press("j")
      end
      selected(tostring(index))
      press("<CR>")
    else
      press(tostring(index))
    end
    assert(vim.api.nvim_buf_get_name(0) == vim.uv.fs_realpath(files[index]))
    restored()
  elseif case == "create" or case == "cancel" then
    for _ = 1, 5 do
      press("j")
    end
    selected("n")
    vim.ui.input = function(opts, callback)
      assert(opts.completion == "file")
      callback(case == "create" and "new file.txt" or nil)
    end
    press("<CR>")
    if case == "create" then
      assert(vim.api.nvim_buf_get_name(0) == vim.uv.fs_realpath(project) .. "/new file.txt")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "new content" })
      vim.cmd.write()
      assert(vim.fn.readfile(project .. "/new file.txt")[1] == "new content")
      restored()
    else
      selected("n")
      assert(vim.bo.filetype == "dashboard")
    end
  elseif case == "find" then
    local called = 0
    vim.api.nvim_feedkeys = function(keys, mode, escape)
      assert(keys == ":find " and mode == "n" and escape == false)
      called = called + 1
    end
    press("k")
    selected("q")
    press("k")
    selected("f")
    press("<CR>")
    press("f")
    assert(called == 2)
  elseif case == "quit" or case == "quit-enter" then
    local called = false
    vim.cmd.quitall = function(...)
      assert(select("#", ...) == 0, "quit must not force-discard changes")
      called = true
    end
    if case == "quit-enter" then
      press("<Up>")
      selected("q")
      press("<CR>")
    else
      press("q")
    end
    assert(called)
  elseif case == "quit-unsaved" then
    local unsaved = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_lines(unsaved, 0, -1, false, { "unsaved text" })
    local quit_ok, quit_err = pcall(press, "q")
    assert(not quit_ok and tostring(quit_err):find("E37:", 1, true), tostring(quit_err))
    assert(vim.bo[unsaved].modified)
    assert(vim.api.nvim_get_current_buf() == buf)
    vim.v.errmsg = ""
  else
    error("unknown test case: " .. case)
  end
  assert(package.loaded["fzf-lua"] == nil)
  assert(vim.v.errmsg == "", vim.v.errmsg)
end, debug.traceback)

vim.ui.input, vim.api.nvim_feedkeys, vim.cmd.quitall = input, feedkeys, quitall
vim.cmd.cd(cwd)
vim.fn.delete(directory, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd.cquit(1)
else
  print("Native dashboard test passed: " .. case)
  vim.cmd("qa!")
end
