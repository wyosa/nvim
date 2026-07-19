return {
	"mfussenegger/nvim-lint",
	ft = {
		"bash",
		"dockerfile",
		"markdown",
		"sh",
		"sql",
		"yaml",
		"yaml.docker-compose",
		"yaml.ghaction",
		"yaml.gitlab",
		"yaml.helm-values",
	},
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

		local sqlfluff_config_files = { ".sqlfluff", "pep8.ini", "pyproject.toml", "setup.cfg", "tox.ini" }
		local function sqlfluff_dialect()
			local dialect = vim.g.sqlfluff_dialect
			return type(dialect) == "string" and dialect ~= "" and dialect or nil
		end

		local function linter_is_available(linter, dialect, sqlfluff_root)
			if linter.name == "sqlfluff" and not dialect and not sqlfluff_root then
				vim.notify_once("Skipping sqlfluff: no dialect or project config found", vim.log.levels.WARN)
				return false
			end

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

				vim.api.nvim_buf_call(bufnr, function()
					local dialect = sqlfluff_dialect()
					local sqlfluff_root = vim.bo.filetype == "sql" and vim.fs.root(bufnr, sqlfluff_config_files) or nil
					if vim.bo.filetype == "sql" then
						lint.linters.sqlfluff.args = { "lint", "--format=json", "-" }
						if dialect then
							table.insert(lint.linters.sqlfluff.args, 2, "--dialect=" .. dialect)
						end
					end

					local ran = false
					lint.try_lint(nil, {
						cwd = sqlfluff_root,
						filter = function(linter)
							local available = linter_is_available(linter, dialect, sqlfluff_root)
							ran = ran or available
							return available
						end,
					})
					if ran then
						last_linted[bufnr] = tick
					end
				end)
			end, 200)
		end

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
					return
				end
				local filetype = vim.bo[args.buf].filetype
				if args.event == "InsertLeave" and (filetype == "sh" or filetype == "bash") then
					return
				end
				schedule_lint(args.buf)
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			group = lint_augroup,
			pattern = "MasonToolsUpdateCompleted",
			callback = function()
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if
						vim.api.nvim_buf_is_loaded(bufnr)
						and vim.bo[bufnr].buftype == ""
						and vim.bo[bufnr].modifiable
					then
						last_linted[bufnr] = nil
						schedule_lint(bufnr)
					end
				end
			end,
		})
	end,
}
