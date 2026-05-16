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

			local to_install = {}
			for _, language in ipairs(languages) do
				if available[language] then
					table.insert(to_install, language)
				end
			end
			treesitter.install(to_install)

			pcall(vim.treesitter.language.register, "yaml", "yaml.ghaction")

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"astro",
					"bash",
					"c",
					"css",
					"dockerfile",
					"go",
					"gomod",
					"gosum",
					"html",
					"javascript",
					"javascriptreact",
					"json",
					"jsonc",
					"lua",
					"markdown",
					"php",
					"python",
					"rust",
					"scss",
					"sql",
					"toml",
					"typescript",
					"typescriptreact",
					"vim",
					"vue",
					"xml",
					"yaml",
					"yaml.ghaction",
					"zsh",
				},
				callback = function(args)
					if vim.bo[args.buf].buftype ~= "" then
						return
					end

					pcall(vim.treesitter.start, args.buf)
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},
}
