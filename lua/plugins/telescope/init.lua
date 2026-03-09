return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},

		config = function()
			require("telescope").setup({
				defaults = {
					layout_config = {
						horizontal = {
							preview_width = 0.50,
						},
						bottom_pane = {
							height = 25,
							preview_cutoff = 120,
						},
					},
				},

				pickers = {
					live_grep = {
						layout_strategy = "horizontal",
					},
					grep_string = {
						layout_strategy = "horizontal",
					},
				},
				extensions = {
					fzf = {},
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set("n", "<space>sa", function()
				builtin.find_files({
					hidden = true,
					no_ignore = true,
				})
			end, { desc = "[S]earch [A]ll" })
			vim.keymap.set("n", "<leader>sv", builtin.git_files, { desc = "[S]earch [V]ersioned" })
			vim.keymap.set("n", "<leader>su", builtin.git_status, { desc = "[S]earch [U]ncommitted" })
			vim.keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "[S]pell [S]uggest" })

			require("plugins.telescope.multigrep").setup()
		end,
	},
}
