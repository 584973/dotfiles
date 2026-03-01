local M = {}

local group = vim.api.nvim_create_augroup("native_yank_blink", { clear = true })

function M.setup(opts)
	opts = opts or {}
	local higroup = opts.higroup or "Visual"
	local timeout = opts.timeout or 140
	local on_visual = opts.on_visual
	if on_visual == nil then
		on_visual = true
	end

	vim.api.nvim_create_autocmd("TextYankPost", {
		group = group,
		callback = function()
			if vim.v.event.operator ~= "y" then
				return
			end

			vim.highlight.on_yank({
				higroup = higroup,
				timeout = timeout,
				on_visual = on_visual,
			})
		end,
	})
end

return M
