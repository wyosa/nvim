-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-hightlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- kill of parent not alive
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.getenv("NVIM") ~= vim.NIL then
			return
		end
		local timer = vim.uv.new_timer()
		if not timer then
			return
		end
		timer:start(
			30000,
			30000,
			vim.schedule_wrap(function()
				local ppid = vim.uv.os_getppid()
				if ppid == nil or ppid == 1 then
					timer:stop()
					timer:close()

					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.bo[buf].modified then
							vim.notify("Parent process exited; modified buffers remain open", vim.log.levels.WARN)
							return
						end
					end

					vim.cmd("quitall")
				end
			end)
		)
	end,
})
