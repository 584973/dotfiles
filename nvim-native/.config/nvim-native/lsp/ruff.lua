return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { { "pyproject.toml", "ruff.toml", ".ruff.toml" }, ".git" },
  on_attach = function(client)
    -- Keep hover documentation with Pyright when both Python servers are available.
    if vim.fn.executable("pyright-langserver") == 1 then
      client.server_capabilities.hoverProvider = false
    end
  end,
}
