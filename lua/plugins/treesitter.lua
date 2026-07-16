return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			local languages = {
				"bash",
				"c",
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

			local to_install = {}
			for _, language in ipairs(languages) do
				if available[language] and not installed[language] then
					table.insert(to_install, language)
				end
			end

			pcall(vim.treesitter.language.register, "yaml", "yaml.ghaction")
			pcall(vim.treesitter.language.register, "yaml", "yaml.docker-compose")
			pcall(vim.treesitter.language.register, "yaml", "yaml.helm-values")

			local filetypes = {
				"astro",
				"bash",
				"c",
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
				"html",
				"htmlangular",
				"javascript",
				"javascriptreact",
				"json",
				"jsonc",
				"lua",
				"markdown",
				"php",
				"python",
				"query",
				"rust",
				"scss",
				"sh",
				"sql",
				"tmux",
				"toml",
				"typescript",
				"typescriptreact",
				"vim",
				"vimdoc",
				"vue",
				"xml",
				"yaml",
				"yaml.docker-compose",
				"yaml.ghaction",
				"yaml.helm-values",
				"zsh",
			}
			local enabled = {}
			for _, filetype in ipairs(filetypes) do
				enabled[filetype] = true
			end

			local function start(bufnr)
				if not enabled[vim.bo[bufnr].filetype] or vim.bo[bufnr].buftype ~= "" then
					return
				end

				if not pcall(vim.treesitter.start, bufnr) then
					return
				end

				local foldexpr = next(vim.lsp.get_clients({
					bufnr = bufnr,
					method = "textDocument/foldingRange",
				})) and "v:lua.vim.lsp.foldexpr()" or "v:lua.vim.treesitter.foldexpr()"
				for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
					vim.wo[win][0].foldmethod = "expr"
					vim.wo[win][0].foldexpr = foldexpr
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function(args)
					start(args.buf)
				end,
			})
			vim.api.nvim_create_autocmd("BufWinEnter", {
				callback = function(args)
					start(args.buf)
				end,
			})

			if #to_install > 0 then
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
