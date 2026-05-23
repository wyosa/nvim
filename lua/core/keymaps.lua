vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Reload/evaluate current Lua config while editing it.
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>x", ":.lua<CR>", { desc = "Execute current Lua line" })
vim.keymap.set("v", "<leader>x", ":lua<CR>", { desc = "Execute selected Lua" })

-- Split navigation.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Split resize.
vim.keymap.set("n", "<M-h>", "<cmd>vertical resize -3<CR>", { desc = "Resize split left" })
vim.keymap.set("n", "<M-l>", "<cmd>vertical resize +3<CR>", { desc = "Resize split right" })
vim.keymap.set("n", "<M-j>", "<cmd>resize +3<CR>", { desc = "Resize split down" })
vim.keymap.set("n", "<M-k>", "<cmd>resize -3<CR>", { desc = "Resize split up" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "[T]oggle [D]iagnostics" })

vim.keymap.set("n", "<leader>tv", function()
	local current = vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = not current })
end, { desc = "[T]oggle diagnostic [V]irtual lines" })

vim.keymap.set("n", "<leader>th", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "[T]oggle inlay [H]ints" })

vim.keymap.set("n", "<leader>ts", function()
	vim.wo.spell = not vim.wo.spell
end, { desc = "[T]oggle [S]pell" })

vim.keymap.set("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
end, { desc = "[T]oggle [W]rap" })

vim.keymap.set("n", "<leader>tl", function()
	vim.wo.list = not vim.wo.list
end, { desc = "[T]oggle [L]ist chars" })
