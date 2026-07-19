local config = require("lazy.core.config")
local errors = _G.NVIM_CONFIG_SMOKE_ERRORS or {}
local lock = vim.json.decode(table.concat(vim.fn.readfile(config.options.lockfile), "\n"))

local plugins = {}
for name, plugin in pairs(config.plugins) do
	assert(vim.uv.fs_stat(plugin.dir), "Plugin is not installed: " .. name)
	local locked = assert(lock[name], "Plugin is missing from lazy-lock.json: " .. name)
	local commit = vim.trim(vim.fn.system({ "git", "-C", plugin.dir, "rev-parse", "HEAD" }))
	assert(vim.v.shell_error == 0, "Unable to read plugin revision: " .. name)
	assert(commit == locked.commit, ("Plugin revision differs from lazy-lock.json: %s"):format(name))

	if name ~= "lazy.nvim" then
		table.insert(plugins, plugin)
	end
end

require("lazy").load({ plugins = plugins, wait = true })
local blink_ready = vim.wait(1000, function()
	return package.loaded["blink.cmp.completion"] ~= nil or #errors > 0
end, 10)
for _, plugin in ipairs(plugins) do
	assert(plugin._.loaded, "Plugin did not load: " .. plugin.name)
end

assert(blink_ready and package.loaded["blink.cmp.completion"], "blink.cmp asynchronous setup did not complete")
local completion_item = vim.lsp.config["*"].capabilities.textDocument.completion.completionItem
assert(completion_item.snippetSupport, "blink.cmp LSP capabilities were not registered")
assert(#errors == 0, "Plugin smoke test errors:\n" .. table.concat(errors, "\n"))

print("plugin smoke checks passed")
