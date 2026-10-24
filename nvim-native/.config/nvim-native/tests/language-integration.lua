local directory = vim.fn.tempname()
local cwd = vim.fn.getcwd()
local cases = {
  { file = "sample.lua", content = { "local x=1", "print(x)" }, servers = { "lua_ls" }, formatter = "stylua", expected = "local x = 1" },
  { file = "main.go", content = { "package main", "func main(){println(1)}" }, servers = { "gopls" }, formatter = "gofmt", expected = "func main() { println(1) }" },
  { file = "sample.py", content = { "import os", "x=1" }, servers = { "pyright", "ruff" }, formatter = "black", expected = "x = 1" },
  { file = "sample.ts", content = { 'const value:number="text";' }, servers = { "ts_ls" }, formatter = "prettier", expected = 'const value: number = "text";' },
  { file = "index.html", content = { "<div> <p>hello</p> <p>world</p> </div>" }, servers = { "html" }, formatter = "prettier", expected = "\n  <p>hello</p>\n" },
}

local ok, err = xpcall(function()
  vim.fn.mkdir(directory, "p")
  vim.fn.writefile({ "module example.com/native-test", "", "go 1.20" }, directory .. "/go.mod")
  vim.fn.writefile({ "{}" }, directory .. "/.luarc.json")
  vim.fn.writefile({ "[project]", 'name = "native-test"', 'version = "0.0.0"' }, directory .. "/pyproject.toml")
  vim.fn.writefile({ '{"private":true}' }, directory .. "/package.json")
  vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, directory .. "/tsconfig.json")
  vim.cmd.cd(vim.fn.fnameescape(directory))

  for _, case in ipairs(cases) do
    vim.fn.writefile(case.content, directory .. "/" .. case.file)
    vim.cmd.edit({ args = { directory .. "/" .. case.file }, bang = true })
    local buf = vim.api.nvim_get_current_buf()
    for _, name in ipairs(case.servers) do
      if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
        assert(vim.wait(20000, function()
          local clients = vim.lsp.get_clients({ bufnr = buf, name = name })
          return #clients > 0 and clients[1].initialized
        end, 50), name .. " did not attach")
        assert(vim.fn.maparg("gd", "n", false, true).buffer == 1)
        print(name .. " attached to " .. case.file)
        if name == "lua_ls" then
          local client = vim.lsp.get_clients({ bufnr = buf, name = name })[1]
          local params = { textDocument = { uri = vim.uri_from_bufnr(buf) }, position = { line = 0, character = 6 } }
          local hover = client:request_sync("textDocument/hover", params, 10000, buf)
          assert(hover and hover.result, "Lua hover response missing")
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local x=math." })
          params.position = { line = 0, character = 13 }
          params.context = { triggerKind = 2, triggerCharacter = "." }
          assert(vim.wait(10000, function()
            local completion = client:request_sync("textDocument/completion", params, 1000, buf)
            if not completion or not completion.result then return false end
            local items = completion.result.items or completion.result
            return #items > 0
          end, 100), "Lua completion list empty after server warm-up")
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, case.content)
          print("Lua hover and completion responses received")
        end
        if name == "ts_ls" then
          assert(vim.wait(10000, function()
            for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
              if diagnostic.code == 2322 then return true end
            end
            return false
          end, 50), "TypeScript did not report type mismatch")
          print("TypeScript diagnostics received")
        end
        if name == "ruff" then
          assert(vim.wait(10000, function()
            for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
              if diagnostic.code == "F401" then return true end
            end
            return false
          end, 50), "Ruff did not report unused import")
          print("Ruff diagnostics received")
        end
      else
        print("SKIP " .. name .. ": executable missing")
      end
    end
    if vim.fn.executable(case.formatter) == 1 then
      require("formatting").format()
      assert(vim.wait(15000, function()
        return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):find(case.expected, 1, true) ~= nil
      end, 50), case.formatter .. " did not format " .. case.file)
      print(case.formatter .. " formatted " .. case.file)
    end
  end
end, debug.traceback)

for _, client in ipairs(vim.lsp.get_clients()) do
  client:stop(true)
end
vim.cmd.cd(vim.fn.fnameescape(cwd))
vim.fn.delete(directory, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd.cquit(1)
else
  print("Native language integration tests passed")
  vim.cmd("qa!")
end
