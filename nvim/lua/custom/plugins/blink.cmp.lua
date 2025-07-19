return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
    {
      'saghen/blink.compat',
      version = '2.*',
      lazy = true,
      opts = {},
    },
    {
      'supermaven-inc/supermaven-nvim',
      dependencies = { 'huijiro/blink-cmp-supermaven' },
      opts = {
        disable_inline_completion = true,
        disable_keymaps = true,
      },
    },
    -- {
    --   'zbirenbaum/copilot.lua',
    --   enabled = false,
    --   dependencies = {
    --     'giuxtaposition/blink-cmp-copilot',
    --     enabled = false,
    --     after = { 'copilot.lua' },
    --     setup = function() end,
    --   },
    --   config = function()
    --     require('copilot').setup {
    --       suggestion = { enabled = false },
    --       panel = { enabled = false },
    --     }
    --   end,
    -- },
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },

    appearance = { nerd_font_variant = 'mono' },

    completion = {
      documentation = { auto_show = true },
      menu = {
        draw = {
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'source_name', gap = 2 },
          },
        },
      },
    },

    sources = {
      default = {
        'lsp',
        'path',
        'snippets',
        'lazydev',
        'supermaven',
        -- 'copilot',
      },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        supermaven = { name = 'Supermaven', module = 'blink-cmp-supermaven', async = true },
        -- copilot = { name = 'copilot', module = 'blink-cmp-copilot', score_offset = 10, async = true },
      },
    },

    fuzzy = { implementation = 'prefer_rust_with_warning' },

    signature = { enabled = true },
  },
}
