local smoke_test = vim.env.NVIM_CONFIG_TEST == "smoke"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_commit = "306a05526ada86a7b30af95c5cc81ffba93fef97"

if smoke_test then
	_G.NVIM_CONFIG_SMOKE_ERRORS = {}
	local original_notify = vim.notify
	vim.notify = function(message, level, opts)
		if level == vim.log.levels.ERROR then
			table.insert(_G.NVIM_CONFIG_SMOKE_ERRORS, tostring(message))
		end
		return original_notify(message, level, opts)
	end
end

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local clone_output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to clone lazy.nvim:\n" .. clone_output)
	end

	local checkout_output = vim.fn.system({ "git", "-C", lazypath, "checkout", lazy_commit })
	if vim.v.shell_error ~= 0 then
		error("Failed to pin lazy.nvim:\n" .. checkout_output)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	local_spec = false,
	install = { missing = not smoke_test },
	spec = {
		{
			"navarasu/onedark.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				require("onedark").setup({
					style = "light",
					transparent = true,
					code_style = {
						comments = "none",
					},
				})
				require("onedark").load()
			end,
		},
		{ import = "plugins" },
	},
})
