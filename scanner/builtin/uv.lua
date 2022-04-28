
local scan = require('plenary.scandir')

local M = {}

M.name = 'uv'


M.exist = function ()
  return pcall(require, 'plenary')
end


local default_opts = {
  extension = nil,
  pattern = '.'
}


M.scan = function (paths, opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts)

  local walk_opts = {}
  if opts.extension then
    walk_opts.search_pattern = '.' .. opts.extension
  end
  if opts.pattern then
    walk_opts.search_pattern = opts.pattern
  end

  local rusult_paths = {}
  opts.on_insert = function(entry, _)
    table.insert(rusult_paths, entry)
    return true
  end
  for _, path in ipairs(paths) do
    scan.scan_dir(path, walk_opts)
  end
  return rusult_paths
end


M.scan_async = function(paths, opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts)

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
