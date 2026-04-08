return {
  'sindrets/diffview.nvim',
  config = function()
    local diffview = require 'diffview'

    vim.keymap.set('n', '<leader>dh', diffview.file_history, { desc = '[D]iff file [H]istory' })
    vim.keymap.set('n', '<leader>dc', diffview.close, { desc = '[D]iff [C]lose' })
    vim.keymap.set('n', '<leader>dd', diffview.open, { desc = '[D]iff open' })
  end,
}
