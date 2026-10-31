return {
  'stevearc/oil.nvim',
  dependencies = { 'echasnovski/mini.nvim' },
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
    vim.keymap.set('n', '<leader>od', function()
      -- The directory shown in Oil, else the current file's, else the working directory
      local dir = require('oil').get_current_dir() or vim.fn.expand '%:p:h'
      if dir == '' or vim.fn.isdirectory(dir) == 0 then
        dir = vim.fn.getcwd()
      end
      vim.ui.open(dir)
    end, { desc = '[O]pen [D]irectory in the file manager' })
  end,
}
