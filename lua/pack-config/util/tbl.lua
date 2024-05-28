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

-- table filter and map
M.tbl_map_filter = function(tbl, ...)
  tbl = convert.force_to_table(tbl)
  if pd.tbl_isempty(tbl) then
    return tbl
  end
  local map_filters = { ... }
  if pd.tbl_isempty(map_filters) then
    return tbl
  end
  local result = {}
  for key, value in pairs(tbl) do
    local r = M.tbl_reduce(map_filters, value, function(r, map_filter)
      -- if the reducer or map_filter is nil then return
      if pd.is_nil(r) or pd.is_nil(map_filter) then
        return r
      end
      return map_filter(r, key)
    end)
    if pd.not_nil(r) then
      result[key] = r
    end
  end
  return result
end

M.tbl_force_extend = function(...)
  return vim.tbl_extend('force', fn.with_default {}(...))
end

M.tbl_force_deep_extend = function(...)
  return vim.tbl_deep_extend('force', fn.with_default {}(...))
end

M.tbl_keep_extend = function(...)
  return vim.tbl_extend('keep', fn.with_default {}(...))
end

M.tbl_keep_deep_extend = function(...)
  return vim.tbl_deep_extend('keep', fn.with_default {}(...))
end

-- ----------------------------------------------------------------------
--    - list op -
-- ----------------------------------------------------------------------

M.list_extend = function(dst, ...)
  local default = fn.with_default {}
  dst = default(dst)
  for _, src in pairs { default(...) } do
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

-- list map_filter
M.list_map_filter = function(tbl, ...)
  tbl = convert.force_to_table(tbl)
  if pd.tbl_isempty(tbl) then
    return tbl
  end
  local map_filters = { ... }
  if pd.tbl_isempty(map_filters) then
    return tbl
  end
  local result = {}
  for _, value in ipairs(tbl) do
    local r = M.tbl_reduce(map_filters, value, function(r, map_filter)
      -- if reducer or map_filter is nil then return
      if pd.is_nil(r) or pd.is_nil(map_filter) then
        return r
      end
      return map_filter(r)
    end)
    -- drop the nil value
    if pd.not_nil(r) then
      table.insert(result, r)
    end
  end
  return result
end

return M
