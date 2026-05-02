return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		indent = { char = "▏", highlight = "IblIndent" },
		scope = { enabled = false },
	},
}
