return {
  'rose-pine/neovim',
  priority = 1000,
  config = function()
    require('rose-pine').setup {
      disable_italic = true,
    }

    vim.cmd 'colorscheme rose-pine'
  end,
}
