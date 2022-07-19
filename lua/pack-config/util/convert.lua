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

  local t = type(result)
  if t == 'string' then
    result = { result }
  elseif t == 'table' then
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
  return tbl.tbl_map_filter(t, function(sub_t)
    return M.to_table_n(sub_t, n - 1)
  end)
end

M.force_to_table = function(v)
  if type(v) == 'nil' or type(v) == 'table' then
    return v
  end
  return { v }
end

M.function_to_table = function(v, error_arg_name)
  if type(v) == 'function' then
    return { v }
  elseif type(v) == 'table' then
    return v
  end

  if error_arg_name ~= nil then
    error('%s require function or table', error_arg_name)
  end
  return v
end

M.string_to_table = function(v, error_arg_name)
  if type(v) == 'string' then
    return { v }
  elseif type(v) == 'table' then
    return v
  end

  if error_arg_name ~= nil then
    error('%s require string or table', error_arg_name)
  end
  return v
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
