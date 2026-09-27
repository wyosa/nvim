-- Shared large-file limits for highlighting, folding and formatting.

local M = {}

-- A file is large when either its line count or byte size exceeds the limit.
function M.is_large(bufnr)
	bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return false
	end
	local lines = vim.api.nvim_buf_line_count(bufnr)
	return lines > (vim.g.large_file_max_lines or 20000)
		or vim.api.nvim_buf_get_offset(bufnr, lines) > (vim.g.large_file_max_bytes or 1024 * 1024)
end

return M
