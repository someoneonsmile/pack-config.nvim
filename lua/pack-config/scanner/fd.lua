local util = require('pack-config.util')
local tbl = util.tbl

local default_cfg = {
  extension = 'lua',
  pattern = '.',
  max_depth = nil,
}

local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'fd'

M.exist = function()
  return vim.fn.executable('fd') == 1
end

M.init = function(opts)
  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)
  if not M.exist() then
    error('not find fd command', vim.log.levels.ERROR)
  end
end

-- @param scan_paths
-- @param opts {}
--  opts.extension
--  opts.pattern
M.scan = function(scan_paths)
  local fd_opts = {}
  if cfg.extension then
    table.insert(fd_opts, '--extension ' .. cfg.extension)
  end
  if cfg.max_depth then
    table.insert(fd_opts, '-d ' .. cfg.max_depth)
  end
  table.insert(fd_opts, cfg.pattern)

  local all_result_paths = {}
  local rv
  local n = #fd_opts
  for _, scan_path in ipairs(scan_paths) do
    fd_opts[n + 1] = scan_path
    rv = vim.fn.system('fd ' .. table.concat(fd_opts, ' '))
    if vim.v.shell_error == 0 then
      local result_paths = vim.split(rv, '\n', { plain = true, trimempty = true })
      all_result_paths = vim.list_extend(all_result_paths, result_paths)
    end
  end
  return all_result_paths
end

M.scan_async = function(scan_paths, opts)
  error('not support async now, please use scan', vim.log.levels.ERROR)
end

return M
