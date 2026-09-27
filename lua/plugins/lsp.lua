-- Shared LSP behavior: reference highlights, navigation, actions and server installation.

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"mason-org/mason.nvim",
				---@module 'mason.settings'
				---@type MasonSettings
				---@diagnostic disable-next-line: missing-fields
				opts = { registry_cache = { refresh = vim.env.NVIM_CONFIG_TEST ~= "smoke" } },
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

			-- Enable features only when the server supports them.
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

			-- A server may change its capabilities after connecting.
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

			-- Server selection is separate from shared settings: core/lsp_servers.lua.
			local lsp_servers = require("core.lsp_servers")

			local smoke_test = vim.env.NVIM_CONFIG_TEST == "smoke"
			require("mason-lspconfig").setup({
				ensure_installed = smoke_test and {} or lsp_servers,
				automatic_enable = not smoke_test and lsp_servers or false,
			})
		end,
	},
}
