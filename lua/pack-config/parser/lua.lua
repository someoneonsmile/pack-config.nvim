local util = require('pack-config.util')
local convert = util.convert
local pred = util.predicate
local tbl = util.tbl

local function can_to_table(v)
  return pred.is_type({ 'function', 'string', 'table', 'nil' }, v)
end

local M = {}

M.name = 'lua'

M.exist = function()
  return true
end

local is_sub, is_subs

is_sub = function(sub)
  return sub ~= nil
    and can_to_table(sub['resources'])
    and pred.is_type({ 'function', 'nil' }, sub['setup'])
    and pred.is_type({ 'function', 'nil' }, sub['config'])
    and is_subs(sub['subs'])
end

is_subs = function(subs)
  if not pred.is_type({ 'function', 'table', 'nil' }, subs) then
    return false
  end
  subs = convert.to_table(subs)
  return tbl.tbl_reduce(subs, true, function(r, sub)
    if not r then
      return r
    end
    return is_sub(sub)
  end)
end

local subs_flatten_merge
subs_flatten_merge = function(s)
  local result = s
  result.resources = convert.to_table_n(result.resources, 2)
  result.setups = { result.setup }
  result.configs = { result.config }

  if pred.tbl_isempty(result['subs']) then
    return result
  end
  result = tbl.tbl_reduce(result['subs'], result, function(r, sub)
    sub = subs_flatten_merge(sub)
    if pred.tbl_isempty(r['resources']) or pred.tbl_isempty(sub['resources']) then
      r['resources'] = r['resources'] or sub['resources']
    else
      r['resources'] = tbl.list_extend(r['resources'], sub['resources'])
    end
    if pred.tbl_isempty(r['setups']) or pred.tbl_isempty(sub['setups']) then
      r['setups'] = r['setups'] or sub['setups']
    else
      r['setups'] = tbl.list_extend(r['setups'], sub['setups'])
    end
    if pred.tbl_isempty(r['configs']) or pred.tbl_isempty(sub['configs']) then
      r['configs'] = r['configs'] or sub['configs']
    else
      r['configs'] = tbl.list_extend(r['configs'], sub['configs'])
    end
    return r
  end)
  result.setup = function()
    if pred.tbl_isempty(result.setups) then
      return
    end
    for _, f in ipairs(result.setups) do
      f()
    end
  end
  result.config = function()
    if pred.tbl_isempty(result.configs) then
      return
    end
    for _, f in ipairs(result.configs) do
      f()
    end
  end
  return result
end

local is_pack = function(pack)
  return pack ~= nil
    and pred.is_type({ 'table' }, pack)
    and type(pack['name']) == 'string'
    and can_to_table(pack['resources'])
    and can_to_table(pack['after'])
    and pred.is_type({ 'function', 'nil' }, pack['setup'])
    and pred.is_type({ 'function', 'nil' }, pack['config'])
    and is_subs(pack['subs'])
end

M.is_pack = is_pack

M.parse = function(pack)
  local result = {}
  result.name = pack.name
  result.resources = convert.to_table_n(pack.resources, 2)
  result.after = convert.to_table(pack.after)
  result.setup = pack.setup
  result.config = pack.config
  result.subs = pack.subs
  subs_flatten_merge(result)
  return result
end

return M
