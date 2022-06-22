local Context = require('pack-config.context')
local const = require('pack-config.const')

local context = Context:new(const.util_id_key)

local M = {}

M.new = function(self, name)
  if context[name] ~= nil then
    error('id_name conflict, name=' .. name)
  end
  context[name] = 0
  return setmetatable({ name = name }, {
    __index = self,
  })
end

M.inc = function(self)
  local old = context[self.name]
  context[self.name] = old + 1
  return old + 1
end

return M
