return {
  'dlyongemallo/diffview-plus.nvim',
  config = function()
    local diffview = require 'diffview'

    -- Core
    vim.keymap.set('n', '<leader>dd', diffview.open, { desc = '[D]iff open' })
    vim.keymap.set('n', '<leader>dc', diffview.close, { desc = '[D]iff [C]lose' })

    -- History
    vim.keymap.set('n', '<leader>dh', function()
      diffview.file_history(nil, {})
    end, { desc = '[D]iff file [H]istory' })
    local function branch_history(branch)
      diffview.file_history(nil, { '--range=' .. branch .. '...HEAD', '--right-only', '--no-merges', '--reverse' })
    end
    vim.keymap.set('n', '<leader>db', function()
      branch_history 'origin/HEAD'
    end, { desc = '[D]iff [B]ranch commits (origin/HEAD)' })
    local last_branch = nil
    -- Completion for the base branch prompt: <Tab> cycles local and remote branches
    -- containing the typed text. Global because 'customlist' needs a v:lua function.
    function _G.diffview_branch_complete(arg_lead)
      local matches = {}
      for _, ref in ipairs(vim.fn.systemlist { 'git', 'for-each-ref', '--format=%(refname)', 'refs/heads', 'refs/remotes' }) do
        -- Skip remote HEAD symrefs, which shorten to a bare "origin"
        local name = not ref:match '/HEAD$' and ref:gsub('^refs/heads/', ''):gsub('^refs/remotes/', '')
        if name and name:find(arg_lead, 1, true) then
          table.insert(matches, name)
        end
      end
      return matches
    end
    vim.keymap.set('n', '<leader>dB', function()
      vim.ui.input({
        prompt = 'Base branch: ',
        default = last_branch or '',
        completion = 'customlist,v:lua.diffview_branch_complete',
      }, function(branch)
        if not branch or branch == '' then
          return
        end
        last_branch = branch
        branch_history(branch)
      end)
    end, { desc = '[D]iff [B]ranch commits (prompt)' })
    vim.keymap.set('n', '<leader>df', function()
      diffview.file_history(nil, { '%' })
    end, { desc = '[D]iff [F]ile history' })
    vim.keymap.set('v', '<leader>dl', ':DiffviewFileHistory<CR>', { desc = '[D]iff [L]ine history' })
    vim.keymap.set('n', '<leader>ds', function()
      diffview.file_history(nil, { '-g', '--range=stash' })
    end, { desc = '[D]iff [S]tash history' })

    -- PR review
    vim.keymap.set('n', '<leader>dm', function()
      diffview.open { 'origin/HEAD...HEAD', '--imply-local' }
    end, { desc = '[D]iff [M]erge-base (PR review)' })
    vim.keymap.set('n', '<leader>dM', function()
      vim.ui.input({
        prompt = 'Base commit/branch: ',
        default = last_branch or '',
        completion = 'customlist,v:lua.diffview_branch_complete',
      }, function(rev)
        if not rev or rev == '' then
          return
        end
        last_branch = rev
        diffview.open { rev .. '..HEAD', '--imply-local' }
      end)
    end, { desc = '[D]iff files against commit (prompt)' })

    -- Panel
    vim.keymap.set('n', '<leader>dt', '<cmd>DiffviewToggleFiles<CR>', { desc = '[D]iff [T]oggle files' })
    vim.keymap.set('n', '<leader>de', '<cmd>DiffviewFocusFiles<CR>', { desc = '[D]iff focus fil[E]s' })
    vim.keymap.set('n', '<leader>dr', '<cmd>DiffviewRefresh<CR>', { desc = '[D]iff [R]efresh' })

    -- Misc
    vim.keymap.set('n', '<leader>do', function()
      local buf = vim.api.nvim_get_current_buf()
      vim.cmd '1tabnext'
      vim.cmd('buffer ' .. buf)
    end, { desc = 'Open diff buffer in working tab' })
  end,
}
