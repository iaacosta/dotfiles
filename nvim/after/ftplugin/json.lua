vim.keymap.set('n', '<leader>fb', function()
  vim.cmd ':%!jq .'
end, { desc = '[F]ormat [B]uffer with jq', buffer = true })
