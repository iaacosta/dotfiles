return {
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb'
    },
    config = function()
      vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true, desc = '[G]it [S]tatus' })
      vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true, desc = '[G]it [B]lame' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {},
  },
}
