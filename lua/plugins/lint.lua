return {

	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile", "BufWritePost" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			dockerfile = { "hadolint" },
			yaml = { "yamllint" },
			["yaml.ghaction"] = { "actionlint", "yamllint" },
			markdown = { "markdownlint-cli2" },
			sql = { "sqlfluff" },
		}
		lint.linters.sqlfluff.args = { "lint", "--format=json", "-" }
		if vim.g.sqlfluff_dialect then
			table.insert(lint.linters.sqlfluff.args, 2, "--dialect=" .. vim.g.sqlfluff_dialect)
		end

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
		local lint_tokens = {}
		local last_linted = {}
		local function schedule_lint(bufnr)
			local tick = vim.api.nvim_buf_get_changedtick(bufnr)
			if last_linted[bufnr] == tick then
				return
			end

			lint_tokens[bufnr] = (lint_tokens[bufnr] or 0) + 1
			local token = lint_tokens[bufnr]
			vim.defer_fn(function()
				if
					not vim.api.nvim_buf_is_valid(bufnr)
					or lint_tokens[bufnr] ~= token
					or vim.api.nvim_buf_get_changedtick(bufnr) ~= tick
				then
					return
				end

				last_linted[bufnr] = tick
				vim.api.nvim_buf_call(bufnr, function()
					lint.try_lint(nil, { filter = linter_is_available })
				end)
			end, 200)
		end

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
					return
				end
				schedule_lint(args.buf)
			end,
		})
	end,
}
