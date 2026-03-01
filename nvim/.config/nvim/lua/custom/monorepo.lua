local M = {}

local project_cache = {}

local monorepo_root_markers = {
	"pnpm-workspace.yaml",
	"yarn.lock",
	"package-lock.json",
	"pnpm-lock.yaml",
	"turbo.json",
	"nx.json",
	"lerna.json",
	".git",
}

local function find_project_json_files(root)
	return vim.fs.find("project.json", { path = root, type = "file", limit = math.huge })
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

function M.workspace_root(path)
	return vim.fs.root(path or 0, monorepo_root_markers) or vim.loop.cwd()
end

function M.get_projects(root)
	if project_cache[root] then
		return project_cache[root]
	end

	local projects = {}

	for _, path in ipairs(find_project_json_files(root)) do
		local obj = read_json(path)
		local name = obj and obj.name

		if type(name) == "string" and name ~= "" then
			table.insert(projects, {
				name = name,
				path = path,
			})
		end
	end

	project_cache[root] = projects
	return projects
end

function M.clear_cache(root)
	if root then
		project_cache[root] = nil
	else
		project_cache = {}
	end
end

return M
