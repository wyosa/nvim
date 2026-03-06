local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      'navarasu/onedark.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        require('onedark').setup {
          style = 'light',
          transparent = true,
          code_style = {
            comments = 'none',
          },
        }
        require('onedark').load()
      end,
    },
    { import = "plugins" }
  }
})
