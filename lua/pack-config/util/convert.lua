local util = require('pack-config.util')
local tbl = util.tbl
local M = {}

M.to_table = function(v)
  local result
  if type(v) == 'function' then
    result = v()
  else
    result = v
  end

  if type(result) == 'string' then
    result = { result }
  elseif type(result) == 'table' then
    result = result
  else
    result = {}
  end

  return result
end

function M.to_table_n(t, n)
  if n < 1 then
    return t
  end
  t = M.to_table(t)
  return tbl.tbl_map(t, function(t)
    return M.to_table_n(t, n - 1)
  end)
end

M.force_to_table = function(tbl)
  if type(tbl) == 'nil' or type(tbl) == 'table' then
    return tbl
  end
  return { tbl }
end

M.function_to_table = function(tbl, error_arg_name)
  if type(tbl) == 'function' then
    return { tbl }
  elseif type(tbl) == 'table' then
    return tbl
  end

  if error_arg_name ~= nil then
    error('%s require function or table', error_arg_name)
  end
  return tbl
end

M.string_to_table = function(tbl, error_arg_name)
  if type(tbl) == 'string' then
    return { tbl }
  elseif type(tbl) == 'table' then
    return tbl
  end

  if error_arg_name ~= nil then
    error('%s require string or table', error_arg_name)
  end
  return tbl
end

M.to_bool = function(v)
  if type(v) == 'function' then
    v = v()
  end
  if type(v) ~= 'boolean' then
    v = false
  end
  return v
end

return M
