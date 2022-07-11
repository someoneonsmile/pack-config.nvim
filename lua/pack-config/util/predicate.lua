local Set = require('pack-config.util').set

local M = {}

M.not_nil = function(it)
  return it ~= nil
end

M.is_nil = function(it)
  return it == nil
end

M.is_function = function(f)
  return type(f) == 'function'
end

M.is_empty = function(v)
  local t = type(v)
  if t == 'nil' then
    return true
  end

  if t == 'table' and vim.tbl_isempty(v) then
    return true
  end

  if t == 'string' and vim.trim(v) == '' then
    return true
  end

  return false
end

M.not_empty = function(v)
  return not M.is_empty(v)
end

M.tbl_isempty = function(v)
  return v == nil or vim.tbl_isempty(v)
end

M.tbl_notempty = function(v)
  return not M.tbl_isempty(v)
end

M.is_type = function(types, v)
  vim.validate {
    types = { types, { 'string', 'table' } },
  }

  if type(types) == 'string' then
    types = { types }
  end

  local type_set = Set.from_list(Set, types)
  return Set.contains(type_set, type(v))
end

return M
