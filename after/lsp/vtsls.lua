-- TypeScript and JavaScript imports, inlay hints and Vue support.

local vue_language_server_path = vim.fn.stdpath("data")
	.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}
local js_ts_settings = {
	preferences = {
		importModuleSpecifier = "non-relative",
	},
	inlayHints = {
		parameterNames = { enabled = "all" },
		parameterTypes = { enabled = true },
		variableTypes = { enabled = true },
		propertyDeclarationTypes = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		enumMemberValues = { enabled = true },
	},
}
---@type vim.lsp.Config
return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
	},
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = { vue_plugin },
			},
		},
		typescript = js_ts_settings,
		javascript = js_ts_settings,
	},
}
