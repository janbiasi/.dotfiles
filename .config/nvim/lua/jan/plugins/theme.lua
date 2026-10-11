local theme_path = vim.fn.stdpath 'config' .. '/colors/matugen.lua'
local last_modified

local function reload_theme()
  local stat = vim.uv.fs_stat(theme_path)
  if not stat then return end

  local modified = stat.mtime.sec .. ':' .. stat.mtime.nsec
  if modified == last_modified then return end

  vim.cmd.colorscheme 'matugen'
  last_modified = modified
end

vim.o.termguicolors = true
vim.cmd.colorscheme 'habamax'
reload_theme()

vim.api.nvim_create_autocmd('FocusGained', {
  group = vim.api.nvim_create_augroup('jan-theme', { clear = true }),
  callback = reload_theme,
})
