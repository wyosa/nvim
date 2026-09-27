-- File tree: \ opens or closes it; O opens a file with its system application.

return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- File type icons.
		"MunifTanjim/nui.nvim",
	},
	cmd = { "Neotree" },
	keys = {
		{ "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
	},
	opts = {
		filesystem = {
			use_libuv_file_watcher = true,
			commands = {
				system_open = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()

					local _, err = vim.ui.open(path)
					if err then
						vim.notify(err, vim.log.levels.ERROR)
					end
				end,
			},
			window = {
				mappings = {
					["\\"] = "close_window",
					["O"] = "system_open",
				},
			},
			filtered_items = {
				visible = true,
			},
		},
	},
}
