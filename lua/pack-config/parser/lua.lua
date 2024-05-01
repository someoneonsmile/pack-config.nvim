local util = require('pack-config.util')
local convert = util.convert
local pred = util.predicate
local tbl = util.tbl
local fn = util.fn

local function can_to_table(v)
  return pred.is_type({ 'function', 'string', 'table', 'nil' }, v)
end

local default_cfg = {
  lazy = false,
}

local cfg = default_opts

local M = {}

M.init = fn.once(function(opts)
  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)
end)

M.name = 'lua'

M.exist = function()
  return true
end

local is_sub, is_subs

-- breadth first
is_sub = function(sub)
  return sub ~= nil
    and can_to_table(sub['resources'])
    and pred.is_type({ 'function', 'nil' }, sub['setup'])
    and pred.is_type({ 'function', 'nil' }, sub['config'])
    and pred.is_type({ 'function', 'boolean', 'nil' }, sub['lazy'])
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

  -- parse sub
  result.resources = convert.to_table_n(result.resources, 2)
  result.lazy = convert.to_bool(result.lazy)
  if result.lazy or cfg.lazy then
    result.setup = fn.with_lazy(result.setup)
    result.config = fn.with_lazy(result.config)
  end

  -- collect
  result.setups = { result.setup }
  result.configs = { result.config }

  if pred.tbl_isempty(result['subs']) then
    return result
  end
  result = tbl.tbl_reduce(result['subs'], result, function(r, sub)
    sub = subs_flatten_merge(sub)
    r['resources'] = tbl.list_extend(r['resources'], sub['resources'])
    r['setups'] = tbl.list_extend(r['setups'], sub['setups'])
    r['configs'] = tbl.list_extend(r['configs'], sub['configs'])
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
    and pred.is_type({ 'function', 'boolean', 'nil' }, pack['lazy'])
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
  -- lazy
  -- if convert.to_bool(pack.lazy) or cfg.lazy then
  if pred.is_nil(pack.lazy) and cfg.lazy or convert.to_bool(pack.lazy) then
    result.setup = fn.with_lazy(result.setup)
    result.config = fn.with_lazy(result.config)
  end
  return result
end

return M
