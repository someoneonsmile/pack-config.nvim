local util = require('pack-config.util')
-- local scan = require('plenary.scandir')

local default_cfg = {
  extension = nil,
  pattern = '.',
}

local cfg = default_cfg


-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'uv'

M.exist = function()
  return pcall(require, 'plenary')
end

M.init = function(opts)
  if not M.exist() then
    util.download_pack {
      dist_dir = vim.fn.stdpath('data') .. '/site/pack/common/start/',
      name = 'plenary',
      path = 'nvim-lua/plenary.nvim',
      prompt = 'Download plenary.nvim ? (y for yes)',
    }
  end
  cfg = vim.tbl_deep_extend('force', default_cfg, opts)
end

M.scan = function(paths)
  local walk_opts = {}
  if cfg.extension then
    walk_opts.search_pattern = '.' .. cfg.extension
  end
  if cfg.pattern then
    walk_opts.search_pattern = cfg.pattern
  end

  local rusult_paths = {}
  cfg.on_insert = function(entry, _)
    table.insert(rusult_paths, entry)
    return true
  end
  for _, path in ipairs(paths) do
    -- scan.scan_dir(path, walk_opts)
  end
  return rusult_paths
end

M.scan_async = function(paths, opts)
  opts = vim.tbl_deep_extend('force', default_cfg, opts)

  local walk_opts = {}
  if opts.extension then
    walk_opts.search_pattern = '.' .. opts.extension
  end
  if opts.pattern then
    walk_opts.search_pattern = opts.pattern
  end
  local rusult_paths = {}
  opts.on_insert = function(entry, _)
    local insert = opts.on_insert(entry, typ)
    if insert then
      table.insert(rusult_paths, entry)
    end
    return insert
  end
  for _, path in ipairs(paths) do
    scan.scan_dir_async(path, walk_opts)
  end
  return rusult_paths
end

return M
