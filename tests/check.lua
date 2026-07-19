local script = debug.getinfo(1, "S").source:sub(2)
local root = vim.fs.dirname(vim.fs.dirname(script))

local function read(path)
	return table.concat(vim.fn.readfile(path), "\n")
end

for _, path in ipairs(vim.fn.globpath(root, "**/*.lua", false, true)) do
	local chunk, err = loadfile(path)
	assert(chunk, ("Invalid Lua in %s: %s"):format(path, err))
end

local lock = vim.json.decode(read(root .. "/lazy-lock.json"))
for name, plugin in pairs(lock) do
	assert(
		type(plugin.commit) == "string" and #plugin.commit == 40 and plugin.commit:match("^%x+$"),
		"Invalid lock for " .. name
	)
end

local lazy_commit = read(root .. "/lua/core/lazy.lua"):match('local lazy_commit = "(%x+)"')
assert(lazy_commit == lock["lazy.nvim"].commit, "lazy.nvim bootstrap pin differs from lazy-lock.json")

dofile(root .. "/lua/core/filetypes.lua")
assert(
	vim.filetype.match({ filename = root .. "/tests/fixtures/compose.yaml" }) == "yaml.docker-compose",
	"Docker Compose filetype not detected"
)
assert(
	vim.filetype.match({ filename = root .. "/tests/fixtures/helm/values.yaml" }) == "yaml.helm-values",
	"Helm values filetype not detected"
)
assert(
	vim.filetype.match({ filename = root .. "/tests/fixtures/helm/templates/deployment.yaml" }) == "helm",
	"Helm template filetype not detected"
)

local function check_injection(language, expected_node, expected_matches)
	local fixture = read(("%s/tests/fixtures/injections.%s"):format(root, language))
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(fixture, "\n", { plain = true }))

	local parser, parser_err = vim.treesitter.get_parser(bufnr, language)
	assert(parser, parser_err)
	local tree = assert(parser:parse()[1])
	local query =
		vim.treesitter.query.parse(language, read(("%s/after/queries/%s/injections.scm"):format(root, language)))
	local content_id
	for id, capture in ipairs(query.captures) do
		if capture == "injection.content" then
			content_id = id
			break
		end
	end
	assert(content_id, "Missing injection.content capture for " .. language)

	local found = 0
	for _, match, metadata in query:iter_matches(tree:root(), bufnr, 0, -1, { all = true }) do
		if metadata["injection.language"] == "sql" then
			local nodes = match[content_id] or {}
			for _, node in ipairs(nodes) do
				if vim.treesitter.get_node_text(node, bufnr):find("SELECT", 1, true) then
					assert(#nodes == 1, language .. " injection captures content more than once")
					assert(node:type() == expected_node, language .. " injection captures " .. node:type())
					found = found + 1
				end
			end
		end
	end
	assert(
		found == expected_matches,
		("Expected %d SQL injections for %s, found %d"):format(expected_matches, language, found)
	)
	vim.api.nvim_buf_delete(bufnr, { force = true })
end

check_injection("go", "raw_string_literal_content", 2)
check_injection("javascript", "string_fragment", 1)
check_injection("typescript", "string_fragment", 1)

print("checks passed")
