return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		spec = {
			{ "<leader>c", group = "[C]ode", mode = { "n", "v" } },
			{ "<leader>d", group = "[D]ebug", mode = { "n", "v" } },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>t", group = "[T]oggle", mode = { "n", "v" } },
			{ "<leader>x", group = "Diagnostics/Trouble" },
			{ "<leader>z", group = "Spelling" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		},
	},
}
