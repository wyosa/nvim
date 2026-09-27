-- Validate JSON with schemas for package.json, TypeScript, ESLint and Prettier.

---@type vim.lsp.Config
return {
	settings = {
		json = {
			validate = { enable = true },
			schemaDownload = { enable = true },
			schemas = {
				{
					fileMatch = { "package.json" },
					url = "https://json.schemastore.org/package.json",
				},
				{
					fileMatch = { "tsconfig.json", "tsconfig.*.json" },
					url = "https://json.schemastore.org/tsconfig.json",
				},
				{
					fileMatch = { ".eslintrc", ".eslintrc.json" },
					url = "https://json.schemastore.org/eslintrc.json",
				},
				{
					fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
					url = "https://json.schemastore.org/prettierrc",
				},
			},
		},
	},
}
