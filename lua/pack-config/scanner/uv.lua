local util = require('pack-config.util')

local default_cfg = {
  max_depth = nil,
  match_fn = function(full_name, name, type)
    return vim.endswith(name, '.lua')
  end,
}

local cfg = default_cfg

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
    if cfg.match_fn(full_name, name, type) then
      table.insert(result_paths, full_name)
    end
  end

  for _, path in ipairs(paths) do
    util.fs.walk_dir(path, callback, cfg.max_depth)
  end

  return result_paths
end

M.scan_async = function(paths)
  local result_paths = {}

  local function callback(full_name, name, type)
    if cfg.match_fn(full_name, name, type) then
      table.insert(result_paths, full_name)
    end
  end

  for _, path in ipairs(paths) do
    util.fs.walk_dir_async(path, callback, cfg.max_depth)
  end

  return result_paths
end

return M
