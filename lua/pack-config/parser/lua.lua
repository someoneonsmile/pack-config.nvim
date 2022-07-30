local util = require('pack-config.util')
local convert = util.convert
local pred = util.predicate

local function can_to_table(v)
  return pred.is_type({ 'function', 'string', 'table', 'nil' }, v)
end

local M = {}

M.name = 'lua'

M.exists = true

M.is_pack = function(pack)
  return type(pack['name']) == 'string'
    and can_to_table(pack['resources'])
    and can_to_table(pack['after'])
    and pred.is_type({ 'function', 'nil' }, pack['setup'])
    and pred.is_type({ 'function', 'nil' }, pack['config'])
end

M.parse = function(pack)
  local result = {}
  result.name = pack.name
  result.resources = convert.to_table_n(pack.resources, 2)
  result.after = convert.to_table(pack.after)
  result.setup = pack.setup
  result.config = pack.config
  return result
end

return M
