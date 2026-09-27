-- Detect indentation from the opened file's contents.

return {
	"NMAC427/guess-indent.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
}
