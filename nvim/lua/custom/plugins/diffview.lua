return {
  'sindrets/diffview.nvim',
  config = function()
    local diffview = require 'diffview'

    -- Core
    vim.keymap.set('n', '<leader>dd', diffview.open, { desc = '[D]iff open' })
    vim.keymap.set('n', '<leader>dc', diffview.close, { desc = '[D]iff [C]lose' })

    -- History
    vim.keymap.set('n', '<leader>dh', function()
      diffview.file_history(nil, {})
    end, { desc = '[D]iff file [H]istory' })
    vim.keymap.set('n', '<leader>db', function()
      diffview.file_history(nil, { '--range=origin/HEAD...HEAD', '--right-only', '--no-merges', '--reverse' })
    end, { desc = '[D]iff [B]ranch commits' })
    vim.keymap.set('n', '<leader>df', function()
      diffview.file_history(nil, { '%' })
    end, { desc = '[D]iff [F]ile history' })
    vim.keymap.set('v', '<leader>dl', ':DiffviewFileHistory<CR>', { desc = '[D]iff [L]ine history' })
    vim.keymap.set('n', '<leader>ds', function()
      diffview.file_history(nil, { '-g', '--range=stash' })
    end, { desc = '[D]iff [S]tash history' })

    -- PR review
    vim.keymap.set('n', '<leader>dm', function()
      diffview.open { 'origin/HEAD...HEAD', '--imply-local' }
    end, { desc = '[D]iff [M]erge-base (PR review)' })

    -- Panel
    vim.keymap.set('n', '<leader>dt', '<cmd>DiffviewToggleFiles<CR>', { desc = '[D]iff [T]oggle files' })
    vim.keymap.set('n', '<leader>de', '<cmd>DiffviewFocusFiles<CR>', { desc = '[D]iff focus fil[E]s' })
    vim.keymap.set('n', '<leader>dr', '<cmd>DiffviewRefresh<CR>', { desc = '[D]iff [R]efresh' })
  end,
}
