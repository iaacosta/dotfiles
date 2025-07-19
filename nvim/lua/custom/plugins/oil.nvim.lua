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
    vim.keymap.set('n', '<leader>ex', '<Cmd>echo "you\'re using oil now buddy!"<CR>')
    vim.keymap.set('n', '<leader>oo', '<Cmd>Oil<CR>', { desc = '[O]pen [O]il' })
  end,
}
