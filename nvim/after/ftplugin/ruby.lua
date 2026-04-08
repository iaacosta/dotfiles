vim.keymap.set('n', '<leader>rI', function()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  local lines = vim.api.nvim_buf_get_lines(0, row - 1, row + 2, false)

  local it_line = lines[1]
  local body_line = lines[2]
  local end_line = lines[3]

  if not it_line or not body_line or not end_line then
    vim.notify('Not enough lines', vim.log.levels.WARN)
    return
  end

  local indent = it_line:match '^(%s*)'

  local body = body_line:match '^%s*(.-)%s*$'

  if not end_line:match '^%s*end%s*$' then
    vim.notify('Expected "end" on line ' .. (row + 2), vim.log.levels.WARN)
    return
  end

  local new_line = indent .. 'it { ' .. body .. ' }'

  vim.api.nvim_buf_set_lines(0, row - 1, row + 2, false, { new_line })

  vim.api.nvim_win_set_cursor(0, { row, #indent })
end, { desc = 'Ruby: transform spec to inline' })
