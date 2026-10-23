-- Code review comments on diffview / file buffers (<leader>r* namespace)
--
-- A review is started explicitly and lives in <git-dir>/reviews/active.json until
-- it's finished (archived as markdown, pruned after 30 days) or discarded.
-- Comments are anchored to the revision of the buffer they were made on, so they
-- survive moving between commits in diffview's file history.

local M = {}

local ns = vim.api.nvim_create_namespace 'custom-review'
local archive_ttl = 30 * 24 * 60 * 60

---@type { root: string, git_dir: string, review: { branch: string, started_at: string, comments: table[] } }?
local state = nil
local subjects = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Review' })
end

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return vim.trim(result.stdout)
end

local function repo()
  local out = git { 'rev-parse', '--show-toplevel', '--absolute-git-dir' }
  if not out then
    return nil
  end
  local root, git_dir = unpack(vim.split(out, '\n'))
  return { root = root, git_dir = git_dir }
end

local function reviews_dir(git_dir)
  return git_dir .. '/reviews'
end

local function active_path(git_dir)
  return reviews_dir(git_dir) .. '/active.json'
end

local function persist()
  vim.fn.mkdir(reviews_dir(state.git_dir), 'p')
  vim.fn.writefile({ vim.json.encode(state.review) }, active_path(state.git_dir))
end

local function load()
  local r = repo()
  if not r or vim.fn.filereadable(active_path(r.git_dir)) == 0 then
    return
  end
  local ok, review = pcall(vim.json.decode, table.concat(vim.fn.readfile(active_path(r.git_dir)), '\n'))
  if not ok then
    notify('Could not read ' .. active_path(r.git_dir), vim.log.levels.ERROR)
    return
  end
  state = { root = r.root, git_dir = r.git_dir, review = review }
  notify(('Resumed review on %s (%d comments)'):format(review.branch, #review.comments))
end

local function subject(commit)
  if commit and not subjects[commit] then
    subjects[commit] = git({ 'show', '-s', '--format=%s', commit }, state.root) or ''
  end
  return subjects[commit]
end

-- Buffer identity: which file and revision a buffer shows ------------------

local function rev_key(rev)
  local RevType = require('diffview.vcs.rev').RevType
  if rev.type == RevType.LOCAL then
    return 'local'
  elseif rev.type == RevType.COMMIT then
    return rev.commit
  elseif rev.type == RevType.STAGE then
    return 'stage:' .. rev.stage
  end
end

local function diffview_identity(bufnr)
  local ok, lib = pcall(require, 'diffview.lib')
  local view = ok and lib.get_current_view()
  local entry = view and view.cur_entry
  if not (entry and entry.layout) then
    return nil
  end
  for _, side in ipairs { 'a', 'b' } do
    local file = entry.layout[side] and entry.layout[side].file
    if file and file.bufnr == bufnr then
      local rev = rev_key(file.rev)
      local right = entry.layout.b and entry.layout.b.file
      return rev and {
        path = file.path,
        rev = rev,
        side = side == 'a' and 'old' or 'new',
        -- The commit under review is whatever the right-hand side shows
        commit = right and right.rev.commit,
      }
    end
  end
end

local function file_identity(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if vim.bo[bufnr].buftype ~= '' or name == '' or name:match '^%a[%w+.%-]*://' then
    return nil
  end
  local path = vim.fs.relpath(state.root, vim.uv.fs_realpath(name) or name)
  return path and { path = path, rev = 'local', side = 'new' }
end

local function identity(bufnr)
  return diffview_identity(bufnr) or file_identity(bufnr)
end

-- Rendering ------------------------------------------------------------------

local function render(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local id = state and identity(bufnr)
  if not id then
    return
  end
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for _, c in ipairs(state.review.comments) do
    if c.path == id.path and c.rev == id.rev and c.line_start <= line_count then
      local last = math.min(c.line_end, line_count)
      for line = c.line_start, last do
        vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, 0, { sign_text = '▎', sign_hl_group = 'DiagnosticSignInfo' })
      end
      local virt_lines = {}
      for _, text in ipairs(vim.split(c.body, '\n')) do
        table.insert(virt_lines, { { '  ┃ ' .. text, 'DiagnosticVirtualTextInfo' } })
      end
      vim.api.nvim_buf_set_extmark(bufnr, ns, last - 1, 0, { virt_lines = virt_lines })
    end
  end
end

local function render_visible()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    render(vim.api.nvim_win_get_buf(win))
  end
  vim.cmd 'redrawstatus!'
end

-- Comment editor -------------------------------------------------------------

local function open_editor(title, initial, on_save)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'markdown'
  vim.api.nvim_buf_set_name(buf, 'review://comment/' .. buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(initial, '\n'))
  vim.bo[buf].modified = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = math.min(80, vim.o.columns - 4),
    height = 8,
    border = 'rounded',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
    footer = ' <C-s> or :w save · q cancel ',
    footer_pos = 'center',
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local saved = false
  local function save()
    if saved then
      return
    end
    saved = true
    local body = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'))
    vim.bo[buf].modified = false
    -- Deferred so `:wq` can close the float itself instead of the window below it
    vim.schedule(close)
    if body ~= '' then
      on_save(body)
    end
  end

  vim.api.nvim_create_autocmd('BufWriteCmd', { buffer = buf, callback = save })
  vim.keymap.set({ 'n', 'i' }, '<C-s>', function()
    vim.cmd 'stopinsert'
    save()
  end, { buffer = buf })
  vim.keymap.set('n', 'q', close, { buffer = buf })

  if initial == '' then
    vim.cmd 'startinsert'
  end
end

-- Actions --------------------------------------------------------------------

local function require_active()
  if not state then
    notify('No active review, start one with <leader>rs', vim.log.levels.WARN)
  end
  return state ~= nil
end

local function comments_at_cursor()
  local id = identity(vim.api.nvim_get_current_buf())
  if not id then
    return {}
  end
  local line = vim.fn.line '.'
  return vim.tbl_filter(function(c)
    return c.path == id.path and c.rev == id.rev and c.line_start <= line and line <= c.line_end
  end, state.review.comments)
end

local function with_comment_at_cursor(cb)
  local found = comments_at_cursor()
  if #found == 0 then
    notify('No comment under cursor', vim.log.levels.WARN)
  elseif #found == 1 then
    cb(found[1])
  else
    vim.ui.select(found, {
      prompt = 'Comment',
      format_item = function(c)
        return vim.split(c.body, '\n')[1]
      end,
    }, function(c)
      if c then
        cb(c)
      end
    end)
  end
end

function M.start()
  if state then
    notify(('Review already active (%d comments)'):format(#state.review.comments), vim.log.levels.WARN)
    return
  end
  local r = repo()
  if not r then
    notify('Not in a git repository', vim.log.levels.ERROR)
    return
  end
  state = {
    root = r.root,
    git_dir = r.git_dir,
    review = {
      branch = git({ 'branch', '--show-current' }, r.root) or 'detached',
      started_at = os.date '%Y-%m-%d %H:%M',
      comments = {},
    },
  }
  persist()
  render_visible()
  notify('Review started on ' .. state.review.branch)
end

function M.comment(line_start, line_end)
  if not require_active() then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local id = identity(bufnr)
  if not id then
    notify('This buffer is not part of the repository', vim.log.levels.WARN)
    return
  end
  line_start = line_start or vim.fn.line '.'
  line_end = line_end or line_start
  open_editor('Comment', '', function(body)
    table.insert(state.review.comments, {
      path = id.path,
      rev = id.rev,
      side = id.side,
      commit = id.commit,
      subject = subject(id.commit),
      line_start = line_start,
      line_end = line_end,
      filetype = vim.bo[bufnr].filetype,
      snippet = table.concat(vim.api.nvim_buf_get_lines(bufnr, line_start - 1, line_end, false), '\n'),
      body = body,
    })
    persist()
    render_visible()
  end)
end

function M.edit()
  if not require_active() then
    return
  end
  with_comment_at_cursor(function(c)
    open_editor('Edit comment', c.body, function(body)
      c.body = body
      persist()
      render_visible()
    end)
  end)
end

function M.delete()
  if not require_active() then
    return
  end
  with_comment_at_cursor(function(c)
    state.review.comments = vim.tbl_filter(function(other)
      return other ~= c
    end, state.review.comments)
    persist()
    render_visible()
    notify 'Comment deleted'
  end)
end

function M.list()
  if not require_active() then
    return
  end
  local items = {}
  for _, c in ipairs(state.review.comments) do
    table.insert(items, {
      filename = state.root .. '/' .. c.path,
      lnum = c.line_start,
      end_lnum = c.line_end,
      text = ('[%s] %s'):format(c.rev == 'local' and 'local' or c.rev:sub(1, 7), vim.split(c.body, '\n')[1]),
    })
  end
  vim.fn.setqflist({}, ' ', { title = 'Review comments', items = items })
  vim.cmd 'copen'
end

function M.export()
  local groups, order = {}, {}
  for _, c in ipairs(state.review.comments) do
    local key = c.commit or 'worktree'
    if not groups[key] then
      groups[key] = {}
      table.insert(order, key)
    end
    table.insert(groups[key], c)
  end

  local out = {
    '# Code review',
    '',
    ('Branch `%s` · %d comments'):format(state.review.branch, #state.review.comments),
  }
  for _, key in ipairs(order) do
    local group = groups[key]
    table.sort(group, function(a, b)
      if a.path ~= b.path then
        return a.path < b.path
      end
      return a.line_start < b.line_start
    end)
    local first = group[1]
    table.insert(out, '')
    table.insert(out, key == 'worktree' and '## Working tree' or ('## %s %s'):format(key:sub(1, 7), first.subject))
    for _, c in ipairs(group) do
      local lines = c.line_start == c.line_end and c.line_start or (c.line_start .. '-' .. c.line_end)
      local notes = {}
      if c.side == 'old' then
        table.insert(notes, 'old side')
      end
      if c.rev:match '^stage' then
        table.insert(notes, 'staged')
      end
      local fence = c.snippet:find '```' and '````' or '```'
      vim.list_extend(out, {
        '',
        ('### %s:%s%s'):format(c.path, lines, #notes > 0 and (' (' .. table.concat(notes, ', ') .. ')') or ''),
        '',
        fence .. c.filetype,
        c.snippet,
        fence,
        '',
        c.body,
      })
    end
  end
  return table.concat(out, '\n') .. '\n'
end

local function prune_archive(dir)
  local cutoff = os.time() - archive_ttl
  for name in vim.fs.dir(dir) do
    local path = dir .. '/' .. name
    local stat = vim.uv.fs_stat(path)
    if stat and stat.mtime.sec < cutoff then
      os.remove(path)
    end
  end
end

local function close_review()
  os.remove(active_path(state.git_dir))
  state = nil
  render_visible()
end

local function finish(markdown)
  local dir = reviews_dir(state.git_dir) .. '/archive'
  vim.fn.mkdir(dir, 'p')
  local path = ('%s/%s-%s.md'):format(dir, state.review.branch:gsub('/', '-'), os.date '%Y%m%d-%H%M%S')
  vim.fn.writefile(vim.split(markdown, '\n'), path)
  close_review()
  prune_archive(dir)
  notify('Review finished, archived to ' .. vim.fn.fnamemodify(path, ':~:.'))
end

function M.copy()
  if not require_active() then
    return
  end
  if #state.review.comments == 0 then
    notify('No comments to copy yet', vim.log.levels.WARN)
    return
  end
  local markdown = M.export()
  vim.fn.setreg('+', markdown)
  vim.ui.select({ 'Keep reviewing', 'Finish review' }, {
    prompt = ('Copied %d comments'):format(#state.review.comments),
  }, function(choice)
    if choice == 'Finish review' then
      finish(markdown)
    end
  end)
end

function M.discard()
  if not require_active() then
    return
  end
  vim.ui.select({ 'Cancel', 'Discard' }, {
    prompt = ('Discard review with %d comments?'):format(#state.review.comments),
  }, function(choice)
    if choice == 'Discard' then
      close_review()
      notify 'Review discarded'
    end
  end)
end

function M.status()
  return state and ('● REVIEW %d'):format(#state.review.comments) or ''
end

-- Setup ----------------------------------------------------------------------

local group = vim.api.nvim_create_augroup('custom-review', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    load()
    -- Buffers opened at startup entered their windows before the review loaded
    if state then
      render_visible()
    end
  end,
})
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = group,
  callback = function(args)
    if state then
      render(args.buf)
    end
  end,
})
vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'DiffviewDiffBufWinEnter',
  callback = function()
    if state then
      render(vim.api.nvim_get_current_buf())
    end
  end,
})

vim.keymap.set('n', '<leader>rs', M.start, { desc = '[R]eview [S]tart' })
vim.keymap.set('n', '<leader>rc', function()
  M.comment()
end, { desc = '[R]eview [C]omment' })
vim.keymap.set('x', '<leader>rc', function()
  local line_start, line_end = vim.fn.line 'v', vim.fn.line '.'
  vim.cmd 'normal! \27'
  M.comment(math.min(line_start, line_end), math.max(line_start, line_end))
end, { desc = '[R]eview [C]omment range' })
vim.keymap.set('n', '<leader>re', M.edit, { desc = '[R]eview [E]dit comment' })
vim.keymap.set('n', '<leader>rd', M.delete, { desc = '[R]eview [D]elete comment' })
vim.keymap.set('n', '<leader>rl', M.list, { desc = '[R]eview [L]ist comments' })
vim.keymap.set('n', '<leader>ry', M.copy, { desc = '[R]eview cop[Y] (and finish)' })
vim.keymap.set('n', '<leader>rx', M.discard, { desc = '[R]eview discard' })

return M
