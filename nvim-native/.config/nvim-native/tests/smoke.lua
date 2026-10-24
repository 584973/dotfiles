local directory = vim.fn.tempname()
local cwd = vim.fn.getcwd()
local jobs = {}

local ok, err = xpcall(function()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  assert(package.loaded["plugins"] == nil)
  assert(package.loaded["lsp"] == nil)
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
  vim.cmd.cd(vim.fn.fnameescape(directory))

  local search = require("search")
  assert(vim.deep_equal(search.find("smpl", true), { "nested/sample.txt" }))
  assert(#search.find("ignored", true) == 0)
  assert(vim.deep_equal(vim.fn.getcompletion("find smpl", "cmdline"), { "nested/sample.txt" }))
  vim.cmd.find("smpl")
  assert(vim.api.nvim_buf_get_name(0) == directory .. "/nested/sample.txt")

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
