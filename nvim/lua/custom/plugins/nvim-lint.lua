return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    local eslint = require 'custom.util.eslint'

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescript = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      vue = { 'eslint_d' },
      go = { 'golangcilint' },
    }

    -- Make eslint_d fugitive-aware: lint the staged buffer content but resolve
    -- config + ignore rules against the real work-tree path.
    local eslint_d = lint.linters.eslint_d
    local stdin_idx
    for i, arg in ipairs(eslint_d.args) do
      if arg == '--stdin-filename' then
        stdin_idx = i + 1
        break
      end
    end
    if stdin_idx then
      eslint_d.args[stdin_idx] = function()
        return eslint.real_path(0)
      end
    else
      vim.notify('nvim-lint: --stdin-filename not found in eslint_d args; fugitive path patch skipped', vim.log.levels.WARN)
    end
    -- nvim-lint reads `linter.cwd` as a literal string (it only evaluates `args`
    -- functions), so resolve the config root lazily via __index instead.
    setmetatable(eslint_d, {
      __index = function(_, key)
        if key == 'cwd' then
          return eslint.config_root(0)
        end
      end,
    })

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
