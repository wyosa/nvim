-- Open LazyGit inside Neovim with <leader>gl.

return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- Floating window decoration.
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- Load the plugin on the first use of this keybinding.
	keys = {
		{ "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
}
