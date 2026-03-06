-- highlight yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-hightlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
