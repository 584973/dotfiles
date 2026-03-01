local monorepo = require("custom.monorepo")
local terminal = require("custom.terminal")

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
			})
		end
	end

	if #items == 0 then
		vim.notify(opts.empty_message, vim.log.levels.WARN)
		return
	end

	vim.ui.select(items, {
		prompt = opts.prompt,
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end
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
				vim.notify("Cleared cached projects", vim.log.levels.INFO)
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
