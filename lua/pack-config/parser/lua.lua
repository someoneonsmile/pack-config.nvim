local convert = require('pack-config.util.convert')

local function can_to_table(v)
  local t = type(v)
  return t == 'function' or t == 'string' or t == 'table' or t == 'nil'
end

local M = {}

M.name = 'lua'

M.exists = true

M.is_pack = function(pack)
  return pack['is_pack']
      and type(pack['name']) == 'string'
      and can_to_table(pack['resources'])
      and can_to_table(pack['after'])
      and type(pack['setup']) == 'function'
      and type(pack['config']) == 'function'
end

M.parse = function(pack)
  local result = {}
  result.name = pack.name
  result.resources = convert.to_table(pack.resources)
  result.after = convert.to_table(pack.after)
  result.setup = pack.setup
  result.config = pack.config
  return result
end

return M
