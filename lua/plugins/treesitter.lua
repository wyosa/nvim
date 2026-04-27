return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local runtime_files = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)
			local runtime_root = runtime_files[1] and vim.fn.fnamemodify(runtime_files[1], ":h:h:h") or nil
			local runtime_queries = runtime_root and (runtime_root .. "/runtime") or nil
			if runtime_queries and not vim.tbl_contains(vim.opt.rtp:get(), runtime_queries) then
				vim.opt.rtp:append(runtime_queries)
			end

			require("nvim-treesitter").setup({
				ensure_installed = {
					"sql",
					"postgresql",
					"clickhouse",
					"go",
					"typescript",
					"javascript",
					"lua",
					"python",
					"php",
					"c",
					"rust",
					"tsx",
					"vue",
					"angular",
					"html",
					"css",
					"scss",
					"vim",
					"markdown",
					"json",
					"yaml",
					"xml",
					"toml",
					"bash",
					"zsh",
					"fish",
					"tmux",
					"dockerfile",
					"gomod",
					"gosum",
				},
				auto_install = true,
			})

			-- Enable highlighting for all supported filetypes automatically
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"sql",
					"postgresql",
					"clickhouse",
					"go",
					"typescript",
					"javascript",
					"lua",
					"python",
					"php",
					"c",
					"rust",
					"tsx",
					"vue",
					"angular",
					"html",
					"css",
					"scss",
					"vim",
					"markdown",
					"json",
					"yaml",
					"xml",
					"toml",
					"bash",
					"zsh",
					"fish",
					"tmux",
					"dockerfile",
					"gomod",
					"gosum",
				},
				callback = function(args)
					local buf = args.buf
					if vim.bo[buf].buftype == "" then
						vim.schedule(function()
							pcall(vim.treesitter.start, buf)
						end)
					end
				end,
			})
		end,
	},
}
