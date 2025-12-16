local function workspace_root()
	return vim.fs.root(0, {
		"pnpm-workspace.yaml",
		"yarn.lock",
		"package-lock.json",
		"pnpm-lock.yaml",
		"turbo.json",
		"nx.json",
		"lerna.json",
		".git",
	}) or vim.loop.cwd()
end

local function read_json(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end
	local text = table.concat(lines, "\n")
	local ok2, obj = pcall(vim.json.decode, text)
	if not ok2 then
		return nil
	end
	return obj
end

local function find_project_json_files(root)
	return vim.fs.find("project.json", { path = root, type = "file", limit = math.huge })
end

local function floating_term(cmd)
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

local function runTest()
	local root = workspace_root()
	local files = find_project_json_files(root)

	local items = {}
	for _, path in ipairs(files) do
		local obj = read_json(path)
		local name = obj and obj.name
		if type(name) == "string" and name ~= "" then
			table.insert(items, {
				label = string.format("%s  (%s)", name, vim.fn.fnamemodify(path, ":~:.")),
				name = name,
				path = path,
			})
		end
	end

	if #items == 0 then
		vim.notify("No project.json files with a name field found", vim.log.levels.WARN)
		return
	end

	vim.ui.select(items, {
		prompt = "Select project name:",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end
		local project_name = choice.name

		floating_term(string.format("pnpm nx run %s:test", project_name))
	end)
end

vim.api.nvim_create_user_command("RunTest", runTest, {})

vim.keymap.set("n", "<leader>t", runTest, { desc = "run tests on given project" })
