-- Copy path keymaps (<leader>c* namespace)

local function cwd_relative_path()
  return vim.fn.expand '%:.'
end

local function home_relative_path()
  local path = vim.fn.expand '%:p'
  local home = vim.fn.expand '$HOME'
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  return path
end

local function copy_and_notify(result)
  vim.fn.setreg('+', result)
  vim.notify('Copied: ' .. result)
end

vim.keymap.set('n', '<leader>cp', function()
  copy_and_notify(cwd_relative_path())
end, { desc = '[C]opy [P]ath (cwd-relative)' })

vim.keymap.set('n', '<leader>cl', function()
  copy_and_notify(cwd_relative_path() .. ':' .. vim.fn.line '.')
end, { desc = '[C]opy path with [L]ine number (cwd-relative)' })

vim.keymap.set('n', '<leader>ca', function()
  copy_and_notify(home_relative_path())
end, { desc = '[C]opy [A]bsolute path (home-relative)' })
