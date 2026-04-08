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
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local gitsigns = require 'gitsigns'

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal { ']c', bang = true }
            else
              gitsigns.nav_hunk 'next'
            end
          end, { desc = 'Next hunk' })

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal { '[c', bang = true }
            else
              gitsigns.nav_hunk 'prev'
            end
          end, { desc = 'Previous hunk' })

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk, { desc = '[H]unk [S]tage' })
          map('n', '<leader>hr', gitsigns.reset_hunk, { desc = '[H]unk [R]eset' })

          map('v', '<leader>hs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = '[H]unk [S]tage selection' })

          map('v', '<leader>hr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = '[H]unk [R]eset selection' })

          map('n', '<leader>hS', gitsigns.stage_buffer, { desc = '[H]unk [S]tage buffer' })
          map('n', '<leader>hR', gitsigns.reset_buffer, { desc = '[H]unk [R]eset buffer' })
          map('n', '<leader>hp', gitsigns.preview_hunk, { desc = '[H]unk [P]review' })
          map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = '[H]unk preview [I]nline' })

          map('n', '<leader>hb', function()
            gitsigns.blame_line { full = true }
          end, { desc = '[H]unk [B]lame line' })

          map('n', '<leader>hd', gitsigns.diffthis, { desc = '[H]unk [D]iff' })

          map('n', '<leader>hD', function()
            gitsigns.diffthis '~'
          end, { desc = '[H]unk [D]iff ~' })

          map('n', '<leader>hQ', function()
            gitsigns.setqflist 'all'
          end, { desc = '[H]unk [Q]uickfix all' })
          map('n', '<leader>hq', gitsigns.setqflist, { desc = '[H]unk [Q]uickfix' })

          -- Toggles
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle line [B]lame' })
          map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle [W]ord diff' })

          -- Text object
          map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'Select [I]nner [H]unk' })
        end,
      }
    end,
  },
}
