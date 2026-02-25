return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }

    require('mini.surround').setup()

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }

    require('mini.pairs').setup()

    require('mini.bufremove').setup()
    vim.keymap.set('n', '<leader>bd', function()
      require('mini.bufremove').delete()
    end, { desc = '[B]uffer [D]elete' })
  end,
}
