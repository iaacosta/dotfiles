return {
  'stevearc/oil.nvim',
  dependencies = { 'echasnovski/mini.icons', opts = {} },
  lazy = false,
  config = function()
    require('oil').setup {
      win_options = {
        signcolumn = 'yes',
        list = true,
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == '.git' or name == '..'
        end,
      },
    }
    vim.keymap.set('n', '<leader>oo', '<Cmd>Oil<CR>', { desc = '[O]pen [O]il' })
    vim.keymap.set('n', '<leader>bC', '<Cmd>:%bd|e#<CR>', { desc = '[B]uffer [C]lose all' })
  end,
}
