-- Entry point: leader key, core settings, then plugin loading.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

-- Load core settings in this order, before plugins.
require("core.environment")
require("core.filetypes")
require("core.options")
require("core.diagnostic")
require("core.keymaps")
require("core.autocmds")
require("core.folds").setup()
-- Core-only tests do not need plugins.
if vim.env.NVIM_CONFIG_TEST ~= "1" then
	require("core.lazy")
end
