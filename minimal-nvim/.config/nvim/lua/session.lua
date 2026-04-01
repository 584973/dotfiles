local excluded = {
	vim.fn.expand("~/"),
	vim.fn.expand("~/Downloads"),
	"/",
}

local function session_file()
	return vim.fn.stdpath("state") .. "/sessions/" .. vim.fn.sha256(vim.fn.getcwd()) .. ".vim"
end

local function is_excluded()
	local cwd = vim.fn.getcwd()
	for _, dir in ipairs(excluded) do
		if cwd == dir or cwd == dir:gsub("/$", "") then
			return true
		end
	end
	return false
end

vim.api.nvim_create_autocmd("VimEnter", {
	nested = true,
	callback = function()
		if is_excluded() or vim.fn.argc() > 0 then
			return
		end
		local f = session_file()
		if vim.fn.filereadable(f) == 1 then
			vim.cmd("silent! source " .. vim.fn.fnameescape(f))
		end
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		if is_excluded() then
			return
		end
		local dir = vim.fn.fnamemodify(session_file(), ":h")
		vim.fn.mkdir(dir, "p")
		vim.cmd("mksession! " .. vim.fn.fnameescape(session_file()))
	end,
})

