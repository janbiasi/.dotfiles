vim.pack.add { 'https://github.com/folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>e', group = '[E]xplorer' },
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>g', group = '[G]it / GitHub' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
