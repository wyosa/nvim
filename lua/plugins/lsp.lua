return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"mason-org/mason.nvim",
				---@module 'mason.settings'
				---@type MasonSettings
				---@diagnostic disable-next-line: missing-fields
				opts = {},
			},
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local builtin = require("telescope.builtin")

					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
					map("gr", builtin.lsp_references, "[G]oto [R]eferences")
					map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
					map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			---@type table<string, vim.lsp.Config>
			local servers = {
				html = {},
				cssls = {},
				emmet_language_server = {
					filetypes = {
						"astro",
						"css",
						"eruby",
						"html",
						"htmldjango",
						"javascriptreact",
						"less",
						"pug",
						"sass",
						"scss",
						"typescriptreact",
						"vue",
					},
				},
				tailwindcss = {},
				eslint = {},
				astro = {},
				angularls = {},
				vue_ls = {},
				vtsls = {
					filetypes = { "vue" },
					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = {
									{
										name = "@vue/typescript-plugin",
										location = vim.fn.stdpath("data")
											.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
										languages = { "vue" },
										configNamespace = "typescript",
									},
								},
							},
						},
					},
				},
				graphql = {},
				jsonls = {
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
				},
				yamlls = {
					settings = {
						yaml = {
							validate = true,
							keyOrdering = false,
							schemaStore = {
								enable = true,
								url = "https://www.schemastore.org/api/json/catalog.json",
							},
							schemas = {
								["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.0-standalone-strict/all.json"] = {
									"k8s/**/*.yaml",
									"k8s/**/*.yml",
									"kubernetes/**/*.yaml",
									"kubernetes/**/*.yml",
									"manifests/**/*.yaml",
									"manifests/**/*.yml",
								},
								["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
									"*docker-compose*.yaml",
									"*docker-compose*.yml",
									"compose*.yaml",
									"compose*.yml",
								},
								["https://json.schemastore.org/chart.json"] = { "Chart.yaml" },
								["https://json.schemastore.org/kustomization.json"] = {
									"kustomization.yaml",
									"kustomization.yml",
								},
								["https://json.schemastore.org/github-workflow.json"] = {
									".github/workflows/*.yaml",
									".github/workflows/*.yml",
								},
								["https://json.schemastore.org/github-action.json"] = {
									".github/action.yaml",
									".github/action.yml",
								},
								["https://json.schemastore.org/gitlab-ci.json"] = {
									".gitlab-ci.yaml",
									".gitlab-ci.yml",
								},
							},
						},
					},
				},
				taplo = {},
				dockerls = {},
				docker_compose_language_service = {},
				helm_ls = {},
				bashls = {},
				gopls = {},
				pyright = {},
				ruff = {},
				rust_analyzer = {},
				clangd = {},
				intelephense = {},
				sqlls = {},
				marksman = {},
				lua_ls = {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end
						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								version = "LuaJIT",
								path = { "lua/?.lua", "lua/?/init.lua" },
							},
							workspace = {
								checkThirdParty = false,
								library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
									"${3rd}/luv/library",
									"${3rd}/busted/library",
								}),
							},
						})
					end,
					settings = {
						Lua = {},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {
				"html",
				"cssls",
				"emmet_language_server",
				"tailwindcss",
				"eslint",
				"astro",
				"angularls",
				"vue_ls",
				"vtsls",
				"graphql",
				"jsonls",
				"yamlls",
				"taplo",
				"dockerls",
				"docker_compose_language_service",
				"helm_ls",
				"bashls",
				"gopls",
				"pyright",
				"ruff",
				"rust_analyzer",
				"clangd",
				"intelephense",
				"sqlls",
				"marksman",
				"lua_ls",
				"typescript-language-server",
				"prettierd",
				"prettier",
				"stylua",
				"shfmt",
				"shellcheck",
				"hadolint",
				"yamllint",
				"markdownlint",
				"actionlint",
				"gofumpt",
				"goimports",
				"golines",
				"black",
				"isort",
				"sqlfluff",
				"clang-format",
			})
			vim.list_extend(ensure_installed, {})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end
		end,
	},
}
