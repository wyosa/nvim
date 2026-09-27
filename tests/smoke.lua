-- Test installed plugin loading and key settings without installing dependencies.

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

assert(require("mason-lspconfig.settings").current.automatic_enable == false, "Smoke mode enables LSP servers")
assert(require("mason.settings").current.registry_cache.refresh == false, "Smoke mode refreshes the Mason registry")
for _, server in ipairs(require("core.lsp_servers")) do
	assert(not vim.lsp.is_enabled(server), "Smoke mode enabled " .. server)
end
assert(vim.tbl_contains(require("core.lsp_servers"), "angularls"), "Angular LSP is not configured")
assert(vim.tbl_contains(vim.lsp.config.vtsls.filetypes, "vue"), "Vue TypeScript integration was lost")
assert(vim.lsp.config.vtsls.settings.typescript.preferences.importModuleSpecifier == "non-relative")
assert(vim.tbl_contains(vim.lsp.config.yamlls.filetypes, "yaml.github-action"), "Action metadata has no YAML LSP")
assert(type(vim.lsp.config.lua_ls.on_init) == "function", "Lua workspace settings were lost")

local lint = require("lint")
assert(
	not vim.tbl_contains(lint._resolve_linter_by_ft("yaml.github-action"), "actionlint"),
	"Action metadata runs actionlint"
)
assert(vim.tbl_contains(lint._resolve_linter_by_ft("yaml.ghaction"), "actionlint"), "Workflows do not run actionlint")

local conform_options = require("lazy.core.plugin").values(config.plugins["conform.nvim"], "opts", false)
local bufnr = vim.api.nvim_create_buf(false, false)
vim.api.nvim_set_current_buf(bufnr)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "int main() { return 0; }" })
vim.bo[bufnr].filetype = "cpp"
assert(vim.treesitter.highlighter.active[bufnr], "C++ Tree-sitter did not start")
assert(conform_options.format_on_save(bufnr), "Format on save is disabled by default")
local toggle = vim.fn.maparg("<leader>tf", "n", false, true).callback
toggle()
assert(not conform_options.format_on_save(bufnr), "Buffer format toggle is ignored")
toggle()
assert(conform_options.format_on_save(bufnr), "Buffer formatting did not resume")

vim.g.large_file_max_bytes = 16
vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = bufnr })
assert(not vim.treesitter.highlighter.active[bufnr], "Tree-sitter stays active on a large buffer")
assert(vim.wo.foldmethod == "manual", "Large buffer keeps expensive folds")
assert(not conform_options.format_on_save(bufnr), "Large buffer is formatted on save")
vim.g.large_file_max_bytes = nil
vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = bufnr })
assert(vim.treesitter.highlighter.active[bufnr], "Tree-sitter does not resume on small buffers")
vim.g.large_file_max_lines = 1
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "int main() {", "  return 0;", "}" })
assert(require("core.large_file").is_large(bufnr), "Line limit is ignored")
vim.g.large_file_max_lines = nil

vim.bo[bufnr].filetype = "htmlangular"
local prettier = require("conform").get_formatter_config("prettier", bufnr)
assert(prettier.options.ft_parsers.htmlangular == "angular", "Angular uses the wrong Prettier parser")
assert(vim.tbl_contains(conform_options.formatters_by_ft.htmlangular, "prettier"))
vim.api.nvim_buf_delete(bufnr, { force = true })
assert(#errors == 0, "Plugin smoke test errors:\n" .. table.concat(errors, "\n"))

print("plugin smoke checks passed")
