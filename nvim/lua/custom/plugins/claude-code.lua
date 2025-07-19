return {
  'greggh/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup {
      window = {
        position = 'float',
      },
      keymaps = {
        toggle = {
          normal = '<leader>oc',
          terminal = nil,
          variants = {
            continue = nil,
            verbose = nil,
          },
        },
      },
    }
  end,
}
