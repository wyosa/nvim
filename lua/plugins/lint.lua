return {

	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile", "BufWritePost" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			zsh = { "shellcheck" },
			dockerfile = { "hadolint" },
			yaml = { "yamllint" },
			["yaml.ghaction"] = { "actionlint", "yamllint" },
			markdown = { "markdownlint-cli2" },
			sql = { "sqlfluff" },
		}
		lint.linters.sqlfluff.args = {
			"lint",
			function()
				return "--dialect=" .. (vim.g.sqlfluff_dialect or "postgres")
			end,
			"--format=json",
			"-",
		}
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
					return
				end
				vim.api.nvim_buf_call(args.buf, function()
					lint.try_lint()
				end)
			end,
		})
	end,

}