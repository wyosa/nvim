return {
	{
		"neovim/nvim-lspconfig",
		ft = {
			"aspnetcorerazor",
			"astro",
			"astro-markdown",
			"bash",
			"blade",
			"c",
			"clojure",
			"cpp",
			"css",
			"cuda",
			"django-html",
			"dockerfile",
			"edge",
			"eelixir",
			"ejs",
			"elixir",
			"erb",
			"eruby",
			"go",
			"gohtml",
			"gohtmltmpl",
			"gomod",
			"gotmpl",
			"gowork",
			"graphql",
			"haml",
			"handlebars",
			"hbs",
			"heex",
			"helm",
			"html",
			"html-eex",
			"htmlangular",
			"htmldjango",
			"jade",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"leaf",
			"less",
			"liquid",
			"lua",
			"markdown",
			"markdown.mdx",
			"mdx",
			"mysql",
			"mustache",
			"njk",
			"nunjucks",
			"objc",
			"objcpp",
			"php",
			"postcss",
			"proto",
			"pug",
			"python",
			"razor",
			"reason",
			"rescript",
			"rust",
			"sass",
			"scss",
			"sh",
			"slim",
			"sql",
			"stylus",
			"sugarss",
			"svelte",
			"templ",
			"toml",
			"typescript",
			"typescriptreact",
			"twig",
			"vue",
			"yaml",
			"yaml.docker-compose",
			"yaml.ghaction",
			"yaml.gitlab",
			"yaml.helm-values",
			"zsh",
		},
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
			local folds = require("core.folds")
			local lsp_highlight_buffers = {}
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })
			local detach_augroup = vim.api.nvim_create_augroup("lsp-detach", { clear = true })

			local function disable_document_highlight(bufnr)
				vim.lsp.util.buf_clear_references(bufnr)
				vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = bufnr })
				vim.api.nvim_clear_autocmds({ group = detach_augroup, buffer = bufnr })
				lsp_highlight_buffers[bufnr] = nil
			end

			local function setup_client_features(client, bufnr)
				if
					client:supports_method("textDocument/documentHighlight", bufnr)
					and not lsp_highlight_buffers[bufnr]
				then
					lsp_highlight_buffers[bufnr] = true
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = bufnr,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = bufnr,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						buffer = bufnr,
						group = detach_augroup,
						callback = function(event)
							for _, attached in ipairs(vim.lsp.get_clients({ bufnr = event.buf })) do
								if
									attached.id ~= event.data.client_id
									and attached:supports_method("textDocument/documentHighlight", event.buf)
								then
									return
								end
							end

							disable_document_highlight(event.buf)
						end,
					})
				elseif
					lsp_highlight_buffers[bufnr]
					and not next(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/documentHighlight" }))
				then
					disable_document_highlight(bufnr)
				end

				folds.update(bufnr)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buf = event.buf, desc = "LSP: " .. desc })
					end
					local telescope = function(picker)
						return function()
							require("telescope.builtin")[picker]()
						end
					end
					local code_action = function()
						pcall(require, "telescope")
						vim.lsp.buf.code_action()
					end

					map("gd", telescope("lsp_definitions"), "[G]oto [D]efinition")
					map("grr", telescope("lsp_references"), "[G]oto [R]eferences")
					map("gI", telescope("lsp_implementations"), "[G]oto [I]mplementation")
					map("<leader>D", telescope("lsp_type_definitions"), "Type [D]efinition")
					map("<leader>ds", telescope("lsp_document_symbols"), "[D]ocument [S]ymbols")
					map("<leader>ws", telescope("lsp_dynamic_workspace_symbols"), "[W]orkspace [S]ymbols")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", code_action, "[C]ode [A]ction", { "n", "x" })
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client then
						setup_client_features(client, event.buf)
					end
				end,
			})

			for _, method in ipairs({ "client/registerCapability", "client/unregisterCapability" }) do
				local handler = vim.lsp.handlers[method]
				vim.lsp.handlers[method] = function(err, result, context, config)
					local response = handler(err, result, context, config)
					local client = vim.lsp.get_client_by_id(context.client_id)
					if client then
						for bufnr in pairs(client.attached_buffers) do
							setup_client_features(client, bufnr)
						end
					end
					return response
				end
			end

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
			local kubernetes_schema_version = vim.g.kubernetes_schema_version or "master"
			local kubernetes_schema_directory = kubernetes_schema_version == "master" and "master-standalone-strict"
				or kubernetes_schema_version .. "-standalone-strict"
			local kubernetes_schema_url = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"
				.. kubernetes_schema_directory
				.. "/all.json"

			local function is_neovim_lua_workspace(path)
				if path == vim.fn.stdpath("config") then
					return true
				end

				return vim.uv.fs_stat(path .. "/lua") ~= nil
					and (vim.uv.fs_stat(path .. "/plugin") ~= nil or vim.uv.fs_stat(path .. "/after") ~= nil)
			end

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
					filetypes = { "yaml", "yaml.gitlab", "yaml.ghaction" },
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
								[kubernetes_schema_url] = {
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
						local path = client.workspace_folders and client.workspace_folders[1].name
						if not path or not is_neovim_lua_workspace(path) then
							return
						end
						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								version = "LuaJIT",
								path = { "lua/?.lua", "lua/?/init.lua" },
							},
							workspace = {
								checkThirdParty = false,
								library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
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

			local smoke_test = vim.env.NVIM_CONFIG_TEST == "smoke"
			require("mason-lspconfig").setup({
				ensure_installed = smoke_test and {} or lsp_servers,
				automatic_enable = smoke_test and false or lsp_servers,
			})
		end,
	},
}
