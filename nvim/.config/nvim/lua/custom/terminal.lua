local state = {
	buf = nil,
	win = nil,
	job = nil,
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
	return vim.fn.jobwait({ state.job }, 0)[1] == -1
end

local function float_config()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	return {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		zindex = 50,
	}
end

local function open_window(buf)
	state.win = vim.api.nvim_open_win(buf, true, float_config())
	vim.wo[state.win].number = false
	vim.wo[state.win].relativenumber = false
	vim.wo[state.win].cursorline = false
end

local function open()
	if is_valid_win(state.win) then
		vim.api.nvim_win_hide(state.win)
		state.win = nil
		return
	end

	if not is_valid_buf(state.buf) or not term_running() then
		state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[state.buf].bufhidden = "hide"
		vim.keymap.set("t", "<Esc>", function()
			vim.api.nvim_win_hide(state.win)
			state.win = nil
		end, { buffer = state.buf })
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

vim.keymap.set("n", "<leader>tt", open, { desc = "Toggle terminal" })

vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if is_valid_win(state.win) then
			vim.api.nvim_win_set_config(state.win, float_config())
		end
	end,
})
