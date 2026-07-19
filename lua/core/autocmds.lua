-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-hightlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Opt in only for launchers that intentionally want orphaned instances closed.
if vim.env.NVIM_PARENT_WATCHDOG == "1" then
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if vim.env.NVIM then
				return
			end
			local timer = vim.uv.new_timer()
			if not timer then
				return
			end
			local warned = false
			timer:start(
				30000,
				30000,
				vim.schedule_wrap(function()
					local ppid = vim.uv.os_getppid()
					if ppid == nil or ppid == 1 then
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if vim.bo[buf].modified or vim.bo[buf].buftype == "terminal" then
								if not warned then
									vim.notify("Parent process exited; active buffers remain open", vim.log.levels.WARN)
									warned = true
								end
								return
							end
						end

						timer:stop()
						timer:close()
						vim.cmd("quitall")
					end
				end)
			)
		end,
	})
end
