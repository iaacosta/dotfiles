-- Base vim options and settings

-- Enable relative numbers
vim.o.number = true
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim (scheduled to avoid startup-time hit)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250

-- Keep sign column always visible
vim.o.signcolumn = 'yes'

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Set colorcolumn to 120 characters
vim.opt.colorcolumn = '120'

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Display certain whitespace characters in the editor
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor
vim.o.scrolloff = 10

-- Raise a dialog instead of failing when buffer has unsaved changes
vim.o.confirm = true

-- Tabs should span 4 spaces
vim.o.tabstop = 4

-- Disable .netrwhist
vim.g.netrw_dirhistmax = 0
