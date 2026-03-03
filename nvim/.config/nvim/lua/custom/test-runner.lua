local monorepo = require("custom.monorepo")
local terminal = require("custom.terminal")

local RECENT_PROJECTS_FILE = vim.fn.stdpath("state") .. "/monorepo_recent_projects.json"
local RECENT_LIMIT = 25

local recent_loaded = false
local recent_projects = {}

local function normalize_root(root)
	return vim.fs.normalize(root or monorepo.workspace_root())
end

local function load_recent_projects()
	if recent_loaded then
		return
	end

	recent_loaded = true
	local ok, lines = pcall(vim.fn.readfile, RECENT_PROJECTS_FILE)
	if not ok then
		return
	end

	local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	if ok_decode and type(decoded) == "table" then
		recent_projects = decoded
	end
end

local function persist_recent_projects()
	local ok_encode, encoded = pcall(vim.json.encode, recent_projects)
	if not ok_encode then
		return
	end

	local dir = vim.fn.fnamemodify(RECENT_PROJECTS_FILE, ":h")
	vim.fn.mkdir(dir, "p")
	vim.fn.writefile({ encoded }, RECENT_PROJECTS_FILE)
end

local function truncate_recent_projects(root)
	local by_root = recent_projects[root]
	if type(by_root) ~= "table" then
		return
	end

	local pairs_by_last_used = {}
	for project, last_used in pairs(by_root) do
		table.insert(pairs_by_last_used, { project = project, last_used = last_used })
	end

	table.sort(pairs_by_last_used, function(a, b)
		return a.last_used > b.last_used
	end)

	for idx = RECENT_LIMIT + 1, #pairs_by_last_used do
		by_root[pairs_by_last_used[idx].project] = nil
	end
end

local function mark_project_used(root, project_name)
	load_recent_projects()

	local normalized_root = normalize_root(root)
	recent_projects[normalized_root] = recent_projects[normalized_root] or {}
	recent_projects[normalized_root][project_name] = os.time()

	truncate_recent_projects(normalized_root)
	persist_recent_projects()
end

local function project_last_used(root, project_name)
	load_recent_projects()

	local by_root = recent_projects[normalize_root(root)]
	if type(by_root) ~= "table" then
		return 0
	end
	return tonumber(by_root[project_name]) or 0
end

local function invalidate_project_cache(root)
	monorepo.clear_cache(root)
end

local function select_project(opts)
	local root = monorepo.workspace_root()
	local projects = monorepo.get_projects(root)

	local items = {}
	for _, project in ipairs(projects) do
		if not opts.filter or opts.filter(project.name) then
			local path = project.path
			table.insert(items, {
				label = string.format("%s  (%s)", project.name, vim.fn.fnamemodify(path, ":~:.")),
				name = project.name,
				path = path,
				last_used = project_last_used(root, project.name),
			})
		end
	end

	if #items == 0 then
		vim.notify(opts.empty_message, vim.log.levels.WARN)
		return
	end

	table.sort(items, function(a, b)
		if a.last_used ~= b.last_used then
			return a.last_used > b.last_used
		end
		return a.name < b.name
	end)

	vim.ui.select(items, {
		prompt = opts.prompt,
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end
		mark_project_used(root, choice.name)
		opts.on_choice(choice)
	end)
end

local function run_nx_target(opts)
	select_project({
		filter = opts.filter,
		prompt = opts.prompt or "Select project name:",
		empty_message = opts.empty_message or "No project.json files with a name field found",
		on_choice = function(choice)
			local args = opts.args or ""
			local suffix = args ~= "" and (" " .. args) or ""
			terminal.popup_terminal(string.format("pnpm nx run %s:%s%s", choice.name, opts.target, suffix))
		end,
	})
end

local function register_commands()
	local commands = {
		{
			name = "RunMonorepoTest",
			callback = function()
				run_nx_target({
					target = "test",
					filter = function(name)
						return not name:match("%-e2e$")
					end,
				})
				vim.notify("Running tests", vim.log.levels.INFO)
			end,
		},
		{
			name = "RunMonorepoPlaywrightTest",
			callback = function()
				run_nx_target({
					target = "e2e",
					filter = function(name)
						return name:match("%-e2e$")
					end,
					prompt = "Select Playwright project name:",
				})
				vim.notify("Running playwright tests", vim.log.levels.INFO)
			end,
		},
		{
			name = "RunMonorepoPlaywrightUI",
			callback = function()
				run_nx_target({
					target = "e2e",
					args = "--ui",
					filter = function(name)
						return name:match("%-e2e$")
					end,
					prompt = "Select Playwright project name:",
				})
				vim.notify("Opening playwright UI", vim.log.levels.INFO)
			end,
		},
		{
			name = "ProjectCacheClear",
			callback = function()
				invalidate_project_cache()
				recent_projects = {}
				persist_recent_projects()
				vim.notify("Cleared cached projects and recent project history", vim.log.levels.INFO)
			end,
		},
		{
			name = "RunTest",
			callback = function()
				terminal.popup_terminal("pnpm test")
				vim.notify("Running tests", vim.log.levels.INFO)
			end,
		},
		{
			name = "RunPlaywrightTest",
			callback = function()
				terminal.popup_terminal("pnpm e2e")
				vim.notify("Running playwright tests", vim.log.levels.INFO)
			end,
		},
		{
			name = "RunPlaywrightUI",
			callback = function()
				terminal.popup_terminal("pnpm e2e:ui")
				vim.notify("Opening playwright UI", vim.log.levels.INFO)
			end,
		},
	}

	for _, command in ipairs(commands) do
		vim.api.nvim_create_user_command(command.name, command.callback, {})
	end
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufDelete" }, {
	pattern = "project.json",
	callback = function(event)
		invalidate_project_cache(monorepo.workspace_root(event.file))
	end,
})

register_commands()
