local M = {}

local function set_folds(bufnr, foldexpr, foldmethod)
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		vim.wo[win][0].foldmethod = foldmethod
		vim.wo[win][0].foldexpr = foldexpr
	end
end

function M.update(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return
	end

	if next(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" })) then
		set_folds(bufnr, "v:lua.vim.lsp.foldexpr()", "expr")
		return
	end

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if ok and parser then
		set_folds(bufnr, "v:lua.vim.treesitter.foldexpr()", "expr")
	else
		set_folds(bufnr, "0", "manual")
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("folds", { clear = true })
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = group,
		callback = function(event)
			M.update(event.buf)
		end,
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(event)
			vim.schedule(function()
				M.update(event.buf)
			end)
		end,
	})
	vim.api.nvim_create_autocmd("LspDetach", {
		group = group,
		callback = function(event)
			vim.schedule(function()
				M.update(event.buf)
			end)
		end,
	})
end

return M
