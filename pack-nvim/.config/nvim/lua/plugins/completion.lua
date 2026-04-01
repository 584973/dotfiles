require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-space>"] = {}, -- disabled: tmux leader
    ["<CR>"] = { "accept", "fallback" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})
