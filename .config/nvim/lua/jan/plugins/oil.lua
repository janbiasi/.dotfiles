vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

require('oil').setup {
  default_file_explorer = true,
  view_options = { show_hidden = true },
}

vim.keymap.set('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory', silent = true })
vim.keymap.set('n', '<leader>et', '<Cmd>Oil --float<CR>', { desc = '[E]xplorer [T]oggle', silent = true })
