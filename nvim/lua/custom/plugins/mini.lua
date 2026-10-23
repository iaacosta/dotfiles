return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }

    require('mini.surround').setup()

    -- Single icon provider; the mock serves plugins that expect nvim-web-devicons
    -- (telescope, diffview)
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()

    local statusline = require 'mini.statusline'
    statusline.setup {
      use_icons = vim.g.have_nerd_font,
      content = {
        -- Default layout plus an indicator while a code review is active
        active = function()
          local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
          local git = statusline.section_git { trunc_width = 40 }
          local diff = statusline.section_diff { trunc_width = 75 }
          local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
          local lsp = statusline.section_lsp { trunc_width = 75 }
          local filename = statusline.section_filename { trunc_width = 140 }
          local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
          local location = statusline.section_location { trunc_width = 75 }
          local search = statusline.section_searchcount { trunc_width = 75 }
          local review = require('custom.review').status()

          return statusline.combine_groups {
            { hl = mode_hl, strings = { mode } },
            { hl = 'DiagnosticVirtualTextWarn', strings = { review } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          }
        end,
      },
    }

    require('mini.pairs').setup()

    require('mini.bufremove').setup()
    vim.keymap.set('n', '<leader>bd', function()
      require('mini.bufremove').delete()
    end, { desc = '[B]uffer [D]elete' })
  end,
}
