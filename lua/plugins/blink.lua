return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	version = "1.*",
	opts = {
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
			},
			ghost_text = { enabled = true },
		},
		sources = { default = { "lsp", "path", "snippets", "buffer" } },
		snippets = { preset = "default" },
		fuzzy = { implementation = vim.env.NVIM_CONFIG_TEST == "smoke" and "lua" or "prefer_rust" },
		signature = { enabled = true },
	},
}
