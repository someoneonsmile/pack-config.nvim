local util = require('pack-config.util')
local fn = util.fn
local convert = util.convert
local pd = util.predicate

local M = {}

-- ----------------------------------------------------------------------
--    - table op -
-- ----------------------------------------------------------------------

M.tbl_distinct = function(tbl)
  local see = {}
  for k, v in pairs(tbl) do
    if see[k] == nil then
      see[k] = v
    end
  end
  return see
end

-- reduce
-- @param f(result, value, key)
M.tbl_reduce = function(tbl, init, f)
  if pd.tbl_isempty(tbl) then
    return init
  end
  local result = init
  for k, v in pairs(tbl) do
    result = f(result, v, k)
  end
  return result
end

-- filter and map
M.tbl_filter_map = function(tbl, filters, maps)
  tbl = convert.force_to_table(tbl)
  if pd.tbl_isempty(tbl) then
    return tbl
  end
  filters = convert.force_to_table(filters)
  maps = convert.force_to_table(maps)
  if pd.tbl_isempty(filters) and pd.tbl_isempty(maps) then
    return tbl
  end
  local result = {}
  for key, value in pairs(tbl) do
    local pass = M.tbl_reduce(filters, true, function(r, filter)
      return r and filter(value, key)
    end)
    if pass then
      result[key] = M.tbl_reduce(maps, value, function(r, map)
        return map(r)
      end)
    end
  end
  return result
end

M.tbl_filter = function(tbl, filters)
  return M.tbl_filter_map(tbl, filters)
end

M.tbl_map = function(tbl, maps)
  return M.tbl_filter_map(tbl, nil, maps)
end

M.tbl_force_extend = function(...)
  return vim.tbl_extend('force', fn.with_default {} (...))
end

M.tbl_force_deep_extend = function(...)
  return vim.tbl_deep_extend('force', fn.with_default {} (...))
end

-- ----------------------------------------------------------------------
--    - list op -
-- ----------------------------------------------------------------------

M.list_extend = function(dst, ...)
  for _, src in pairs { ... } do
    vim.list_extend(dst, src)
  end
  return dst
end

M.list_distinct = function(key_extractor, list)
  local see = {}
  local result = {}
  for _, v in pairs(list) do
    local k = key_extractor(v)
    if not see[k] then
      see[k] = true
      table.insert(result, v)
    end
  end
  return result
end

M.list_to_map = function(list, key_extractor, value_extractor)
  if list == nil then
    return {}
  end

  local result_map = {}
  for _, v in ipairs(list) do
    local k = key_extractor(v)
    if k ~= nil and result_map[k] == nil then
      result_map[k] = value_extractor(v)
    end
  end
  return result_map
end

return M
