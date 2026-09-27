-- Add LuaJIT and Neovim libraries only to Neovim Lua workspaces.

local function is_neovim_lua_workspace(path)
	if path == vim.fn.stdpath("config") then
		return true
	end

	return vim.uv.fs_stat(path .. "/lua") ~= nil
		and (vim.uv.fs_stat(path .. "/plugin") ~= nil or vim.uv.fs_stat(path .. "/after") ~= nil)
end

---@type vim.lsp.Config
return {
	on_init = function(client)
		local path = client.workspace_folders and client.workspace_folders[1].name
		if not path or not is_neovim_lua_workspace(path) then
			return
		end
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			workspace = {
				checkThirdParty = false,
				library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
					"${3rd}/luv/library",
					"${3rd}/busted/library",
				}),
			},
		})
	end,
	settings = {
		Lua = {},
	},
}
