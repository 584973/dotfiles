-- Floating terminal utilities (no plugin required)
local M = {}

local state = {
	buf = nil, -- terminal buffer
	win = nil, -- floating window id
	job = nil, -- terminal job id
}

local function is_valid_win(win)
	return win and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
	return buf and vim.api.nvim_buf_is_valid(buf)
end

local function term_running()
	if not state.job then
		return false
	end
	local res = vim.fn.jobwait({ state.job }, 0)[1]
	return res == -1
end

local function float_config()
	local columns = vim.o.columns
	local lines = vim.o.lines
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((lines - height) / 2)
	local col = math.floor((columns - width) / 2)
	return {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = row,
		col = col,
		zindex = 50,
	}
end

local function open_window(buf)
	state.win = vim.api.nvim_open_win(buf, true, float_config())
	vim.wo[state.win].winblend = 0
	vim.wo[state.win].number = false
	vim.wo[state.win].relativenumber = false
	vim.wo[state.win].cursorline = false
end

function M.open()
	if is_valid_win(state.win) then
		vim.api.nvim_set_current_win(state.win)
		vim.cmd("startinsert")
		return
	end

	if not is_valid_buf(state.buf) or not term_running() then
		state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[state.buf].bufhidden = "hide"
		open_window(state.buf)
		vim.api.nvim_buf_call(state.buf, function()
			state.job = vim.fn.termopen(vim.o.shell, {
				on_exit = function()
					state.job = nil
					if is_valid_win(state.win) then
						pcall(vim.api.nvim_win_close, state.win, true)
					end
					state.win = nil
				end,
			})
		end)
	else
		open_window(state.buf)
	end

	vim.cmd("startinsert")
end

function M.new()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	open_window(buf)
	vim.api.nvim_buf_call(buf, function()
		vim.fn.termopen(vim.o.shell)
	end)
	vim.cmd("startinsert")
end

function M.popup_terminal(cmd)
	local buf = vim.api.nvim_create_buf(false, true)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
	})

	vim.fn.termopen(cmd)
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>tt", M.new, { desc = "Terminal: new float" })

-- Resize float when the editor size changes
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if is_valid_win(state.win) then
			vim.api.nvim_win_set_config(state.win, float_config())
		end
	end,
})

return M
