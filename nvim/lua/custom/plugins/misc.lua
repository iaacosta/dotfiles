return {
  {
    'NMAC427/guess-indent.nvim',
    opts = {},
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup { signs = false }
      vim.keymap.set('n', '<leader>st', ':TodoTelescope<CR>', { desc = '[T]odo [T]elescope' })
    end,
  },
}
