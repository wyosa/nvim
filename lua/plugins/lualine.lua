local function lsp_clients()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end

	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	table.sort(names)

	return "LSP: " .. table.concat(names, ",")
end

local function dap_status()
	local dap = package.loaded["dap"]
	if not dap then
		return ""
	end

	return dap.status()
end

local function lazy_updates()
	local ok, status = pcall(require, "lazy.status")
	if ok and status.has_updates() then
		return status.updates()
	end

	return ""
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_b = { "branch", "diff" },
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_x = {
					"diagnostics",
					lsp_clients,
					dap_status,
					lazy_updates,
					"encoding",
					"filetype",
				},
			},
			extensions = {
				"neo-tree",
				"fzf",
				"lazy",
				"quickfix",
			},
		},
	},
}
