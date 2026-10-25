local directory = vim.fn.tempname()
local cwd = vim.fn.getcwd()
local jobs = {}

local ok, err = xpcall(function()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  assert(package.loaded["plugins"] == nil)
  assert(package.loaded["lsp"] ~= nil)
  assert(vim.o.packpath == vim.env.VIMRUNTIME)
  for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
    assert(not path:find("/pack/", 1, true) or vim.startswith(path, vim.env.VIMRUNTIME .. "/"), path)
  end

  vim.fn.mkdir(directory .. "/nested", "p")
  vim.fn.mkdir(directory .. "/node_modules", "p")
  vim.fn.mkdir(directory .. "/.git", "p")
  vim.fn.writefile({ "needle one", "needle two", "a/b | c" }, directory .. "/nested/sample.txt")
  vim.fn.writefile({ "needle ignored" }, directory .. "/node_modules/ignored.txt")
  vim.fn.writefile({ "needle ignored" }, directory .. "/.git/ignored.txt")
  vim.fn.writefile({ "space" }, directory .. "/space name.txt")
  vim.fn.writefile({ "hidden root fixture" }, directory .. "/.hidden-root.txt")
  vim.fn.mkdir(directory .. "/.config/nested/.inner", "p")
  vim.fn.writefile({ "hidden directory fixture" }, directory .. "/.config/nested/.inner/hidden-deep.txt")
  vim.fn.writefile({ "nested dotfile fixture" }, directory .. "/nested/.hidden-nested.txt")
  for _, path in ipairs({ ".venv", ".config/.git", "nested/node_modules", ".config/.venv" }) do
    vim.fn.mkdir(directory .. "/" .. path, "p")
    vim.fn.writefile({ "excluded fixture" }, directory .. "/" .. path .. "/ignored.txt")
  end
  vim.cmd.cd(vim.fn.fnameescape(directory))

  local search = require("search")
  assert(vim.deep_equal(search.find("smpl", true), { "nested/sample.txt" }))
  assert(#search.find("ignored", true) == 0)
  assert(vim.deep_equal(vim.fn.getcompletion("find smpl", "cmdline"), { "nested/sample.txt" }))
  vim.cmd.find("smpl")
  assert(vim.api.nvim_buf_get_name(0) == directory .. "/nested/sample.txt")

  assert(vim.deep_equal(search.find("hidden-root", true), { ".hidden-root.txt" }))
  assert(vim.deep_equal(search.find("hidden-deep", true), { ".config/nested/.inner/hidden-deep.txt" }))
  assert(vim.deep_equal(search.find("hidden-nested", true), { "nested/.hidden-nested.txt" }))
  assert(vim.tbl_contains(search.find("", true), ".hidden-root.txt"))
  assert(vim.deep_equal(vim.fn.getcompletion("find hidden-root", "cmdline"), { ".hidden-root.txt" }))
  vim.cmd.find("hidden-root")
  assert(vim.api.nvim_buf_get_name(0) == directory .. "/.hidden-root.txt")

  local input = vim.ui.input
  local notify = vim.notify
  local pattern = "needle"
  local notices = {}
  vim.ui.input = function(_, callback) callback(pattern) end
  vim.notify = function(message) notices[#notices + 1] = message end
  search.grep()
  assert(#vim.fn.getqflist() == 2)
  assert(vim.bo.buftype == "quickfix")
  vim.cmd.cclose()
  pattern = "a/b | c"
  search.grep()
  assert(#vim.fn.getqflist() == 1)
  vim.cmd.cclose()
  pattern = "no-such-pattern"
  search.grep()
  assert(#notices == 1 and notices[1]:find("E480", 1, true), vim.inspect(notices))
  assert(#vim.fn.getqflist() == 0)
  pattern = nil
  search.grep()
  vim.ui.input = input
  vim.notify = notify

  vim.cmd.edit(vim.fn.fnameescape(directory .. "/space name.txt"))
  vim.fn.maparg("e", "n", false, true).callback()
  assert(vim.bo.filetype == "netrw")
  assert(vim.b.netrw_curdir == directory)
  local explorer = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  assert(not explorer:find("Quick Help:", 1, true))
  assert(not explorer:find("EXPLORE", 1, true))
  local namespace = vim.api.nvim_get_namespaces()["explorer-hints"]
  local function check_guide()
    local marks = vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, { details = true })
    assert(#marks == 1 and marks[1][2] == 0 and marks[1][3] == 0)
    local details = marks[1][4]
    assert(details.virt_lines_above and details.virt_lines_leftcol)
    assert(vim.wait(200, function()
      return vim.fn.winsaveview().topfill == #details.virt_lines
    end), "explorer guide is outside the viewport")
    local lines = {}
    for _, chunks in ipairs(details.virt_lines) do
      local text = {}
      for _, chunk in ipairs(chunks) do
        text[#text + 1] = chunk[1]
      end
      lines[#lines + 1] = table.concat(text)
    end
    local guide = table.concat(lines, "\n")
    for _, hint in ipairs({
      "EXPLORE", "Enter Open", "- Parent", "% New file", "d New folder",
      "R Rename", "D Delete", "o Split down", "v Split right", "gh Hidden", "F1 Help",
    }) do
      assert(guide:find(hint, 1, true), "missing explorer hint: " .. hint)
    end
    assert(vim.fn.maparg("<F1>", "n"):find("netrw-quickhelp", 1, true))
  end
  check_guide()
  vim.cmd.Explore(vim.fn.fnameescape(directory .. "/nested"))
  assert(vim.b.netrw_curdir == directory .. "/nested")
  check_guide()
  vim.cmd.Explore(vim.fn.fnameescape(directory))
  check_guide()
  local entry = vim.fn.search("^space name.txt$", "nw")
  assert(entry > 0)
  local browser = vim.api.nvim_get_current_win()
  for _, key in ipairs({ "o", "v" }) do
    vim.api.nvim_win_set_cursor(browser, { entry, 0 })
    vim.api.nvim_feedkeys(key, "xt", false)
    local split = vim.api.nvim_get_current_win()
    assert(split ~= browser)
    assert(vim.api.nvim_buf_get_name(0) == directory .. "/space name.txt")
    local opened = vim.api.nvim_win_get_position(split)
    local original = vim.api.nvim_win_get_position(browser)
    if key == "o" then
      assert(opened[1] > original[1] and opened[2] == original[2], "split did not open below")
    else
      assert(opened[2] > original[2] and opened[1] == original[1], "split did not open to the right")
    end
    vim.api.nvim_win_close(split, false)
    vim.api.nvim_set_current_win(browser)
  end
  vim.api.nvim_win_set_cursor(0, { entry, 0 })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "xt", false)
  assert(vim.api.nvim_buf_get_name(0) == directory .. "/space name.txt")
  assert(#vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, {}) == 0)
  vim.cmd.enew()
  vim.api.nvim_buf_set_name(0, directory .. "/100%native.txt")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "changed" })
  local tabline = vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true }).str
  assert(tabline:find("100%native.txt +", 1, true), tabline)
  assert(vim.api.nvim_eval_statusline(vim.o.statusline, {}).str:find("100%native.txt", 1, true))

  local toggle = vim.fn.maparg(" tt", "n", false, true).callback
  local window = vim.api.nvim_get_current_win()
  toggle()
  local terminal = vim.api.nvim_get_current_buf()
  local floating = vim.api.nvim_get_current_win()
  assert(vim.bo.buftype == "terminal")
  assert(vim.api.nvim_win_get_config(floating).relative == "editor")
  jobs[#jobs + 1] = vim.b.terminal_job_id
  assert(vim.fn.jobwait(jobs, 0)[1] == -1)
  vim.cmd.stopinsert()
  toggle()
  assert(not vim.api.nvim_win_is_valid(floating))
  assert(vim.api.nvim_get_current_win() == window)
  toggle()
  assert(vim.api.nvim_get_current_buf() == terminal)
  vim.api.nvim_exec_autocmds("VimResized", {})
  vim.fn.maparg("<Esc>", "t", false, true).callback()
  assert(vim.api.nvim_get_current_win() == window)
  assert(vim.fn.exists(":LazyGit") == 0)
  assert(vim.fn.maparg(" lg", "n") == "")
  assert(vim.fn.maparg("<C-h>", "n") ~= "")
end, debug.traceback)

for _, job in ipairs(jobs) do
  vim.fn.jobstop(job)
end
vim.cmd.cd(vim.fn.fnameescape(cwd))
vim.fn.delete(directory, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd.cquit(1)
else
  print("Native config smoke tests passed")
  vim.cmd("qa!")
end
