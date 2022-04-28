local M = {}


local default_opts = {
  extension = nil,
  pattern = '.'
}


M.name = 'fd'


M.exist = function()
  return vim.fn.executable('fd')
end


-- @param scan_paths
-- @param opts {}
--  opts.extension
--  opts.pattern
M.scan = function(scan_paths, opts)

  opts = vim.tbl_deep_extend('force', default_opts, opts)

  local fd_opts = {}
  if opts.extension then
    table.insert(fd_opts, '--extension ' .. opts.extension)
  end
  table.insert(fd_opts, opts.pattern)

  local all_result_paths = {}
  local rv
  for _, scan_path in ipairs(scan_paths) do
    rv = vim.fn.system('fd ' .. table.concat(fd_opts, ' '))
    if vim.v.shell_error == 0 then
      local result_paths = vim.split(rv, '\n', {plain = true, trimempty = true})
      result_paths = vim.tbl_map(function(path)
        return (vim.endswith(scan_path, '/') and scan_path:sub(1, -2) or scan_path) .. path:sub(2, -1)
      end, result_paths)

      all_result_paths = vim.tbl_extend('force', all_result_paths, result_paths)
    end
  end

  return all_result_paths
end


M.scan_async = function(scan_paths, opts)
  error('not support async now, please use scan', vim.log.levels.ERROR)
end


return M
