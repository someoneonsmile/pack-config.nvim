local util = require('pack-config.util')
local Set = util.set
local tbl = util.tbl

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
  ---@diagnostic disable-next-line: redundant-parameter
  vim.validate {
    types = { types, { 'string', 'table' } },
  }

  if type(types) == 'string' then
    types = { types }
  end

  local extra_types = {
    list = function(v_extra)
      return type(v_extra) == 'table' and vim.tbl_islist(v_extra)
    end,
    map = function(v_extra)
      return type(v_extra) == 'table' and not vim.tbl_islist(v_extra)
    end,
  }

  local type_set = Set.from_list(Set, types)
  return Set.contains(type_set, type(v))
    or tbl.tbl_reduce(types, false, function(r, t)
      if r then
        return r
      end
      return extra_types[t] ~= nil and extra_types[t](v)
    end)
end

return M
