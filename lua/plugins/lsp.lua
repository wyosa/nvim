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
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			local lsp_highlight_buffers = {}
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })
			local detach_augroup = vim.api.nvim_create_augroup("lsp-detach", { clear = true })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local builtin = require("telescope.builtin")

					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buf = event.buf, desc = "LSP: " .. desc })
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
					if
						client
						and client:supports_method("textDocument/documentHighlight", event.buf)
						and not lsp_highlight_buffers[event.buf]
					then
						lsp_highlight_buffers[event.buf] = true
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
							buffer = event.buf,
							group = detach_augroup,
							callback = function(event2)
								for _, attached in ipairs(vim.lsp.get_clients({ bufnr = event2.buf })) do
									if
										attached.id ~= event2.data.client_id
										and attached:supports_method("textDocument/documentHighlight", event2.buf)
									then
										return
									end
								end

								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = event2.buf })
								lsp_highlight_buffers[event2.buf] = nil
							end,
						})
					end

					if client and client:supports_method("textDocument/foldingRange", event.buf) then
						vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
					end
				end,
			})

			local lsp_servers = {
				"vtsls",
				"vue_ls",
				"eslint",
				"html",
				"cssls",
				"tailwindcss",
				"emmet_language_server",
				"jsonls",
				"yamlls",
				"lua_ls",
				"gopls",
				"pyright",
				"ruff",
				"rust_analyzer",
				"sqlls",
				"taplo",
				"bashls",
				"dockerls",
				"docker_compose_language_service",
				"marksman",
				"astro",
				"graphql",
				"helm_ls",
				"clangd",
				"intelephense",
			}

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

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

			---@type table<string, vim.lsp.Config>
			local server_configs = {
				html = {},
				cssls = {},
				tailwindcss = {},
				eslint = {},
				vue_ls = {},
				astro = {},
				graphql = {},
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
				vtsls = {
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
				},
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
					filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values", "yaml.ghaction" },
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							format = { enable = true },
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

			for _, name in ipairs(lsp_servers) do
				vim.lsp.config(name, server_configs[name] or {})
			end

			require("mason-lspconfig").setup({
				ensure_installed = lsp_servers,
				automatic_enable = lsp_servers,
			})
		end,
	},
}
