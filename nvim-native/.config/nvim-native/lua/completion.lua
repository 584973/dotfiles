vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("native-completion", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
    return "<C-y>"
  end
  return "<CR>"
end, { expr = true, desc = "Accept completion or insert newline" })

for key, direction in pairs({ ["<Tab>"] = 1, ["<S-Tab>"] = -1 }) do
  vim.keymap.set({ "i", "s" }, key, function()
    if vim.snippet.active({ direction = direction }) then
      return "<Cmd>lua vim.snippet.jump(" .. direction .. ")<CR>"
    end
    return key
  end, { expr = true, silent = true, desc = "Jump snippet placeholder or insert Tab" })
end
