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

		local function linter_is_available(linter)
			local cmd = linter.cmd
			if type(cmd) == "function" then
				local ok, result = pcall(cmd)
				if not ok then
					vim.notify_once(
						("Skipping %s: unable to resolve linter command"):format(linter.name),
						vim.log.levels.WARN
					)
					return false
				end
				cmd = result
			end

			if not cmd or vim.fn.executable(cmd) == 0 then
				vim.notify_once(
					("Skipping %s: %s is not executable"):format(linter.name, cmd or "missing command"),
					vim.log.levels.WARN
				)
				return false
			end

			return true
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
					return
				end
				vim.api.nvim_buf_call(args.buf, function()
					lint.try_lint(nil, { filter = linter_is_available })
				end)
			end,
		})
	end,
}
