-- Tree-sitter languages, parser installation and highlighting for regular files.

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			local treesitter_augroup = vim.api.nvim_create_augroup("treesitter", { clear = true })
			-- Keep the tmux parser and queries together at a pinned revision.
			vim.api.nvim_create_autocmd("User", {
				group = treesitter_augroup,
				pattern = "TSUpdate",
				callback = function()
					local parsers = require("nvim-treesitter.parsers")
					parsers.tmux = parsers.tmux
						or {
							install_info = {
								url = "https://github.com/Freed-Wu/tree-sitter-tmux",
								revision = "26c21424955a719bfdbb3f595265a5322200c261",
								generate = true,
								queries = "queries",
							},
						}
				end,
			})
			-- Languages that need highlighting.
			local languages = {
				"bash",
				"c",
				"cpp",
				"css",
				"diff",
				"dockerfile",
				"fish",
				"gitcommit",
				"gitignore",
				"go",
				"gomod",
				"gosum",
				"graphql",
				"helm",
				"html",
				"javascript",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"rust",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"vue",
				"xml",
				"yaml",
				"zsh",
				"angular",
				"astro",
				"php",
				"scss",
				"tmux",
			}

			treesitter.setup()

			local available = {}
			for _, language in ipairs(treesitter.get_available()) do
				available[language] = true
			end

			local installed = {}
			for _, language in ipairs(treesitter.get_installed()) do
				installed[language] = true
			end

			-- Install only missing parsers from the available registry.
			local to_install = {}
			for _, language in ipairs(languages) do
				if available[language] and not installed[language] then
					table.insert(to_install, language)
				end
			end

			local enabled = {}
			for _, language in ipairs(languages) do
				enabled[language] = true
			end

			-- Disable highlighting for large files and restore it when they become smaller.
			local function start(bufnr)
				if not vim.api.nvim_buf_is_loaded(bufnr) then
					return
				end
				local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
				if not enabled[language] or vim.bo[bufnr].buftype ~= "" then
					return
				end

				if require("core.large_file").is_large(bufnr) then
					vim.treesitter.stop(bufnr)
					require("core.folds").update(bufnr)
					return
				end

				if not pcall(vim.treesitter.start, bufnr) then
					return
				end

				require("core.folds").update(bufnr)
			end

			vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "BufWritePost" }, {
				group = treesitter_augroup,
				callback = function(args)
					start(args.buf)
				end,
			})
			if #to_install > 0 and vim.env.NVIM_CONFIG_TEST ~= "smoke" then
				treesitter.install(to_install):await(function(err)
					vim.schedule(function()
						if err then
							vim.notify("Failed to install Tree-sitter parsers: " .. tostring(err), vim.log.levels.ERROR)
							return
						end
						for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
							start(bufnr)
						end
					end)
				end)
			end
		end,
	},
}
