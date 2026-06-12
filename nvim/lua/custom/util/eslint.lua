-- Fugitive-aware eslint helpers.
--
-- vim-fugitive exposes git-staged content through `fugitive://…//0/path` buffers.
-- eslint's default ignore rules drop the `.git//0/…` path, so eslint_d refuses to
-- lint/fix those buffers. These helpers resolve the real work-tree path (and config
-- root) so eslint behaves as if it were operating on the real file while still
-- reading the staged buffer content via --stdin.

local M = {}

-- Return the real work-tree path for a buffer, transparently resolving
-- `fugitive://` buffers via FugitiveReal. Defaults to the current buffer.
function M.real_path(buf)
  buf = buf or 0
  local name = vim.api.nvim_buf_get_name(buf)
  if name:match '^fugitive://' then
    local ok, real = pcall(vim.fn.FugitiveReal, name)
    if ok and real ~= nil and real ~= '' then
      return real
    end
  end
  return name
end

-- Find the eslint config root by walking upward from the buffer's real path.
-- Returns the directory containing an eslint config / package.json, or nil.
function M.config_root(buf)
  local path = M.real_path(buf)
  if path == '' then
    return nil
  end
  local found = vim.fs.find(function(name)
    return name == 'package.json' or name:match '^eslint%.config%.[mc]?[jt]s$' or name:match '^%.eslintrc'
  end, { upward = true, path = vim.fs.dirname(path), type = 'file' })
  return found[1] and vim.fs.dirname(found[1]) or nil
end

return M
