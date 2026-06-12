-- General keymaps (topic-specific keymaps live in their own modules)

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Pathetic"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Pathetic"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Pathetic"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Pathetic"<CR>')

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Maximize current window both vertically and horizontally (restore with <C-w>=)
vim.keymap.set('n', '<C-w>m', '<C-w>_<C-w>|', { desc = '[M]aximize window (height + width)' })
