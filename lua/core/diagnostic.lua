vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	signs = true,
	float = { source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = {
		source = "if_many",
		spacing = 2,
	},
	virtual_lines = false,
	jump = {
		on_jump = function(diagnostic, bufnr)
			if not diagnostic then
				return
			end

			vim.diagnostic.show(diagnostic.namespace, bufnr, { diagnostic }, {
				virtual_lines = { current_line = true },
				virtual_text = false,
			})
		end,
	},
})
