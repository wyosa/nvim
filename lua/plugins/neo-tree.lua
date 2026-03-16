return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	cmd = { "Neotree" },
	keys = {
		{ "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
	},
	opts = {
		filesystem = {
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
