local directory = vim.fn.tempname()
local servers = { "lua_ls", "gopls", "pyright", "ruff", "ts_ls", "html" }

local ok, err = xpcall(function()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  for _, name in ipairs(servers) do
    local config = vim.lsp.config[name]
    assert(vim.lsp.is_enabled(name) == (vim.fn.executable(config.cmd[1]) == 1), name)
    assert(config.capabilities.textDocument.completion.completionItem.snippetSupport)
    vim.lsp.enable(name, false)
  end

  local executable = vim.fn.executable
  for _, present in ipairs({ 0, 1 }) do
    vim.fn.executable = function() return present end
    package.loaded["lsp"] = nil
    require("lsp")
    for _, name in ipairs(servers) do
      assert(vim.lsp.is_enabled(name) == (present == 1), name)
      vim.lsp.enable(name, false)
    end
  end
  vim.fn.executable = executable

  local get_client = vim.lsp.get_client_by_id
  local completion_enable = vim.lsp.completion.enable
  local completion_calls = 0
  local supports_completion = true
  vim.lsp.get_client_by_id = function()
    return {
      id = 12345,
      supports_method = function(_, method)
        return supports_completion and method == "textDocument/completion"
      end,
    }
  end
  vim.lsp.completion.enable = function(enabled, id, buf, opts)
    assert(enabled and id == 12345 and buf == vim.api.nvim_get_current_buf() and opts.autotrigger)
    completion_calls = completion_calls + 1
  end
  vim.api.nvim_exec_autocmds("LspAttach", { buffer = 0, data = { client_id = 12345 } })
  assert(completion_calls == 1)
  for _, key in ipairs({ "gd", " ca", " rn", " gr" }) do
    assert(vim.fn.maparg(key, "n", false, true).buffer == 1, key)
  end
  supports_completion = false
  vim.api.nvim_exec_autocmds("LspAttach", { buffer = 0, data = { client_id = 12345 } })
  assert(completion_calls == 1)
  vim.lsp.get_client_by_id = get_client
  vim.lsp.completion.enable = completion_enable

  local active = vim.snippet.active
  vim.snippet.active = function() return true end
  assert(vim.fn.maparg("<Tab>", "i", false, true).callback() == "<Cmd>lua vim.snippet.jump(1)<CR>")
  assert(vim.fn.maparg("<S-Tab>", "i", false, true).callback() == "<Cmd>lua vim.snippet.jump(-1)<CR>")
  vim.snippet.active = function() return false end
  assert(vim.fn.maparg("<Tab>", "i", false, true).callback() == "<Tab>")
  vim.snippet.active = active

  local pumvisible, complete_info = vim.fn.pumvisible, vim.fn.complete_info
  local enter = vim.fn.maparg("<CR>", "i", false, true).callback
  vim.fn.pumvisible = function() return 1 end
  vim.fn.complete_info = function() return { selected = 0 } end
  assert(enter() == "<C-y>")
  vim.fn.complete_info = function() return { selected = -1 } end
  assert(enter() == "<CR>")
  vim.fn.pumvisible = function() return 0 end
  assert(enter() == "<CR>")
  vim.fn.pumvisible, vim.fn.complete_info = pumvisible, complete_info
  assert(vim.diagnostic.config().virtual_text == true)

  vim.fn.mkdir(directory, "p")
  vim.cmd.enew()
  vim.api.nvim_buf_set_name(0, directory .. "/sample.lua")
  vim.bo.filetype = "lua"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "local x=1" })
  local buf = vim.api.nvim_get_current_buf()
  local system, notify = vim.system, vim.notify
  local warnings = {}
  vim.notify = function(message) warnings[#warnings + 1] = message end
  vim.fn.executable = function() return 1 end
  local callback
  vim.system = function(command, opts, on_exit)
    assert(command[1] == "stylua")
    assert(command[4] == directory .. "/sample.lua")
    assert(opts.stdin == "local x=1\n" and opts.timeout == 10000)
    callback = on_exit
  end
  local format = require("formatting").format
  format()
  callback({ code = 0, stdout = "local x = 1\n", stderr = "" })
  assert(vim.wait(1000, function() return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "local x = 1" end))

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local x=1" })
  format()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local x=2" })
  callback({ code = 0, stdout = "local x = 1\n", stderr = "" })
  assert(vim.wait(1000, function() return #warnings == 1 end))
  assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "local x=2")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local x=1" })
  format()
  callback({ code = 1, stdout = "", stderr = "formatter error" })
  assert(vim.wait(1000, function() return #warnings == 2 end))
  assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "local x=1")
  assert(warnings[2] == "formatter error")
  vim.system = function() error("spawn failed") end
  format()
  assert(#warnings == 3)

  local get_clients, lsp_format = vim.lsp.get_clients, vim.lsp.buf.format
  vim.fn.executable = function() return 0 end
  vim.lsp.get_clients = function() return {} end
  format()
  assert(#warnings == 4)
  vim.lsp.get_clients = function(opts)
    assert(opts.bufnr == buf and opts.method == "textDocument/formatting")
    return { {} }
  end
  local fallback = false
  vim.lsp.buf.format = function(opts) fallback = opts.bufnr == buf and opts.async end
  format()
  assert(fallback)
  vim.lsp.get_clients, vim.lsp.buf.format = get_clients, lsp_format
  vim.fn.executable, vim.system, vim.notify = executable, system, notify
end, debug.traceback)

vim.fn.delete(directory, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd.cquit(1)
else
  print("Native language tests passed (including missing tools and formatter failures)")
  vim.cmd("qa!")
end
