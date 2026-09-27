-- Core editor behavior: files, indentation, search, windows and folds.

vim.o.number = true
vim.o.numberwidth = 1
vim.o.relativenumber = true

vim.o.mouse = "a"
vim.o.showmode = false

-- Use the system clipboard.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true

-- Preserve recovery options for interrupted writes.
vim.o.swapfile = true
vim.o.backup = false
vim.o.writebackup = true

-- Default indentation; language-specific ftplugin files can override it.
vim.o.tabstop = 3
vim.o.shiftwidth = 3
vim.o.softtabstop = 3
vim.o.expandtab = true

-- Search ignores case unless the query contains an uppercase character.
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes:2"
vim.opt.fillchars:append({ eob = " " })
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = false

vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10

vim.o.confirm = true

-- Reload files after external changes.
vim.opt.autoread = true

vim.opt.listchars = {
	tab = "> ",
	trail = ".",
	extends = ">",
	precedes = "<",
	nbsp = "+",
}

-- Open files with all folds expanded.
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
