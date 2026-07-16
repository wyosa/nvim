vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

require("core.filetypes")
require("core.options")
require("core.diagnostic")
require("core.keymaps")
require("core.autocmds")
if vim.env.NVIM_CONFIG_TEST ~= "1" then
	require("core.lazy")
end
