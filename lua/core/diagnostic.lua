vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = true,
	virtual_lines = false,
	jump = { float = true },
})
