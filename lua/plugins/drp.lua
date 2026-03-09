return {
	"andweeb/presence.nvim",
	event = "VeryLazy",
	opts = {
		auto_update = true,
		neovim_image_text = "(｡◕‿‿◕｡)",
		debounce_timeout = 5,
		main_image = "neovim",
		enable_line_number = false,
		show_time = true,

		-- presence settings
		editing_text = "editing %s",
		file_explorer_text = "exploring %s",
		git_commit_text = "committing changes",
		plugin_manager_text = "managing plugins",
		reading_text = "reading %s",
		workspace_text = "workspace: %s",
	},
}
