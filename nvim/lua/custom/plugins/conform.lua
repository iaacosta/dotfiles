local eslint = require 'custom.util.eslint'

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>ff',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat [F]ile',
    },
  },
  opts = {
    notify_on_error = false,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescript = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      json = { 'prettierd' },
      vue = { 'eslint_d' },
    },
    -- Make eslint_d fugitive-aware: fix the staged buffer content but resolve
    -- config + ignore rules against the real work-tree path.
    formatters = {
      eslint_d = {
        args = function(_, ctx)
          return { '--fix-to-stdout', '--stdin', '--stdin-filename', eslint.real_path(ctx.buf) }
        end,
        cwd = function(_, ctx)
          return eslint.config_root(ctx.buf)
        end,
      },
    },
  },
}
