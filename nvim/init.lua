-- Set leader keys (must be set before any keymap or plugin loads)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nerd Font detection (must be set before lazy UI config)
vim.g.have_nerd_font = true

-- Auto-require all custom/*.lua modules (plugins/ is handled by lazy)
local custom_dir = vim.fn.stdpath 'config' .. '/lua/custom'
for _, file in ipairs(vim.fn.glob(custom_dir .. '/*.lua', false, true)) do
  local mod = 'custom.' .. vim.fn.fnamemodify(file, ':t:r')
  require(mod)
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
-- vim: ts=2 sts=2 sw=2 et
