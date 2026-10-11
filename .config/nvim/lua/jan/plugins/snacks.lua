vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {
  lazygit = { enabled = true },
  indent = { enabled = true },
  picker = { enabled = true }, -- required by gh
  gh = { enabled = true },
  gitbrowse = { enabled = true },
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
    },
    preset = {
      keys = {
        { icon = ' ', key = 'e', desc = 'Explore', action = ':Oil' },
        { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
  },
}

vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazy[G]it' })
vim.keymap.set('n', '<leader>gl', function() Snacks.lazygit.log() end, { desc = 'Lazygit [L]og' })
vim.keymap.set({ 'n', 'x' }, '<leader>go', function() Snacks.gitbrowse() end, { desc = 'Git [O]pen in browser' })
vim.keymap.set('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'GitHub [I]ssues (open)' })
vim.keymap.set('n', '<leader>gI', function() Snacks.picker.gh_issue { state = 'all' } end, { desc = 'GitHub [I]ssues (all)' })
vim.keymap.set('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'GitHub [P]Rs (open)' })
vim.keymap.set('n', '<leader>gP', function() Snacks.picker.gh_pr { state = 'all' } end, { desc = 'GitHub [P]Rs (all)' })
