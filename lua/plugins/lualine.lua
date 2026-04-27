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
				lualine_c = {
					{
						"filename",
						path = 1,
					},
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
