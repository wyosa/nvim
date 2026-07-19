local virtual_text = {
	source = "if_many",
	spacing = 2,
}

vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	signs = true,
	float = { source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = virtual_text,
	virtual_lines = false,
	jump = {
		on_jump = function(diagnostic, bufnr)
			if not diagnostic then
				return
			end

			vim.diagnostic.show(diagnostic.namespace, bufnr, nil, {
				virtual_lines = { current_line = true },
				virtual_text = vim.tbl_extend("force", virtual_text, { current_line = false }),
			})
		end,
	},
})
