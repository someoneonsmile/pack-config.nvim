local util = require('pack-config.util')

local default_cfg = {
  extension = 'lua',
  pattern = '.',
}

local cfg = default_cfg

local match = function(s)
  return vim.endswith(s, '.' .. cfg.extension) and s:match(cfg.pattern)
end

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'uv'

M.exist = function()
  return true
end

M.init = function(opts)
  cfg = vim.tbl_deep_extend('force', default_cfg, opts)
end

M.scan = function(paths)
  local result_paths = {}

  local function callback(full_name, name, type)
    if match(name) then
      table.insert(result_paths, full_name)
    end
  end

  for _, path in ipairs(paths) do
    util.fs.walk_dir(path, callback)
  end

  return result_paths
end

M.scan_async = function(paths)
  local result_paths = {}

  local function callback(full_name, name, type)
    if match(name) then
      table.insert(result_paths, full_name)
    end
  end

  for _, path in ipairs(paths) do
    util.fs.walk_dir_async(path, callback)
  end

  return result_paths
end

return M
