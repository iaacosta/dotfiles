return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescript = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
    }
    --
    -- Create autocommand which carries out the actual linting on the specified events.
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })

    -- custom eslint autofix function
    local function eslint_fix()
      local filename = vim.fn.expand '%'
      local filetype = vim.bo.filetype
      local allowed_filetypes = {
        javascript = true,
        javascriptreact = true,
        typescript = true,
        typescriptreact = true,
      }

      if not allowed_filetypes[filetype] then
        vim.notify('custom autofix in linting is only configured for javascript / typescript', vim.log.levels.WARN)
        return
      end

      local view = vim.fn.winsaveview()
      local lint_result = vim.fn.system('eslint_d --fix ' .. vim.fn.shellescape(filename))

      if vim.v.shell_error ~= 0 then
        vim.notify('Error running eslint_d: ' .. lint_result, vim.log.levels.ERROR)
        vim.fn.winrestview(view)
      else
        vim.cmd 'edit!'
        vim.fn.winrestview(view)
        require('lint').try_lint()
      end
    end

    vim.keymap.set('n', '<leader>lf', eslint_fix, { desc = '[L]int [F]ix with eslint_d' })
  end,
}
