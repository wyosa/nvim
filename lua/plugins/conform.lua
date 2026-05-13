return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = {
			timeout_ms = 1500,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },

			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			vue = { "prettierd", "prettier", stop_after_first = true },
			astro = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			scss = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			["yaml.ghaction"] = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			graphql = { "prettierd", "prettier", stop_after_first = true },

			go = { "goimports", "gofumpt", "golines" },
			python = { "ruff_organize_imports", "ruff_format" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			sql = { "sqlfluff" },

			["_"] = { "trim_whitespace", "trim_newlines" },
		},
		formatters = {
			sqlfluff = {
				require_cwd = false,
				args = function()
					return { "fix", "--dialect", vim.g.sqlfluff_dialect or "postgres", "-" }
				end,
			},
		},
	},
}
