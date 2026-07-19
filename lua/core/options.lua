vim.o.number = true
vim.o.numberwidth = 1
vim.o.relativenumber = true

vim.o.mouse = "a"
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true

-- Protect unsaved changes and interrupted writes.
vim.o.swapfile = true
vim.o.backup = false
vim.o.writebackup = true

-- Tabs.
vim.o.tabstop = 3
vim.o.shiftwidth = 3
vim.o.softtabstop = 3
vim.o.expandtab = true

-- Search.
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

-- update buffer content when file changes externally
vim.opt.autoread = true

vim.opt.listchars = {
	tab = "> ",
	trail = ".",
	extends = ">",
	precedes = "<",
	nbsp = "+",
}

vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
