vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      completion = { completionItem = { snippetSupport = true } },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("native-lsp", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
  end,
})

for _, name in ipairs({ "lua_ls", "gopls", "pyright", "ruff", "ts_ls", "html" }) do
  local config = vim.lsp.config[name]
  if vim.fn.executable(config.cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end
