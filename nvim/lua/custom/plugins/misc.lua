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
  {
    'mistricky/codesnap.nvim',
    build = 'make',
    keys = {
      { '<leader>cs', '<cmd>CodeSnap<cr>', mode = 'x', desc = '[C]ode[S]nap' },
    },
    config = function()
      require('codesnap').setup {
        has_line_number = true,
        watermark = '',
        bg_padding = 16,
        mac_window_bar = false,
      }
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
}
