vim.lsp.config("kotlin_lsp", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  -- Prefer the repository root over a module's pom.xml for Maven reactors.
  root_markers = {
    ".git",
    "settings.gradle",
    "settings.gradle.kts",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "workspace.json",
  },
})

vim.lsp.enable({ "lua_ls", "gopls", "pyright", "ts_ls", "html", "kotlin_lsp" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, {})
