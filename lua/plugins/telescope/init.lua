return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		cmd = "Telescope",
		keys = {
			{
				"<leader>sh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "[S]earch [H]elp",
			},
			{
				"<leader>sk",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "[S]earch [K]eymaps",
			},
			{
				"<leader>sf",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "[S]earch [F]iles",
			},
			{
				"<leader>ss",
				function()
					require("telescope.builtin").builtin()
				end,
				desc = "[S]earch [S]elect Telescope",
			},
			{
				"<leader>sw",
				function()
					require("telescope.builtin").grep_string()
				end,
				mode = { "n", "v" },
				desc = "[S]earch current [W]ord",
			},
			{
				"<leader>sg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "[S]earch by [G]rep",
			},
			{
				"<leader>sG",
				function()
					require("plugins.telescope.multigrep").live_multigrep()
				end,
				desc = "[S]earch Multi [G]rep",
			},
			{
				"<leader>sd",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "[S]earch [D]iagnostics",
			},
			{
				"<leader>sr",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "[S]earch [R]esume",
			},
			{
				"<leader>s.",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = "[S]earch Recent Files",
			},
			{
				"<leader>sc",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "[S]earch [C]ommands",
			},
			{
				"<leader><leader>",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Find existing buffers",
			},
			{
				"<leader>sa",
				function()
					require("telescope.builtin").find_files({ hidden = true })
				end,
				desc = "[S]earch [A]ll hidden",
			},
			{
				"<leader>sA",
				function()
					require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
				end,
				desc = "[S]earch [A]bsolutely all",
			},
			{
				"<leader>sv",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "[S]earch [V]ersioned",
			},
			{
				"<leader>su",
				function()
					require("telescope.builtin").git_status()
				end,
				desc = "[S]earch [U]ncommitted",
			},
			{
				"<leader>z=",
				function()
					require("telescope.builtin").spell_suggest()
				end,
				desc = "Spell Suggestions",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},

		config = function()
			local function open_with_trouble(...)
				local ok, trouble = pcall(require, "trouble.sources.telescope")
				if ok then
					trouble.open(...)
				end
			end

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
					mappings = {
						i = { ["<C-t>"] = open_with_trouble },
						n = { ["<C-t>"] = open_with_trouble },
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
		end,
	},
}
