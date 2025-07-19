return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true, desc = '[G]it [S]tatus' })
  end,
}
