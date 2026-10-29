vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("KotlinDependencySources", { clear = true }),
  pattern = "jar://*",
  callback = function(args)
    local archive, entry = args.match:match("^jar://(.-)!/(.+)$")
    if not archive then
      error("Invalid Kotlin dependency source URI: " .. args.match)
    end

    local source = "zipfile://" .. vim.uri_decode(archive) .. "::" .. vim.uri_decode(entry)
    vim.bo[args.buf].buftype = ""
    vim.bo[args.buf].modifiable = true
    vim.fn["zip#Read"](source, 1)
    vim.bo[args.buf].buftype = "nofile"
    vim.bo[args.buf].swapfile = false
    vim.bo[args.buf].readonly = true
    vim.bo[args.buf].modifiable = false
  end,
})
