vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('jan-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
