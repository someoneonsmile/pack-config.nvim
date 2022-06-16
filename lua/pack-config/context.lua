local predicate = require('pack-config.util').predicate

local M = {}

-- regist context to here
local contexts = {}

-- ----------------------------------------------------------------------
--    - regist the context to contexts and return the context -
--    - can call it with context[k] = v and local v = context[k]
--    - and also can call the method context:set(k, v, opts) and context:get(k)
-- ----------------------------------------------------------------------

function M:new(name, o)
  if contexts[name] then
    error(string.format('context_name: %s, has exist'))
  end
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  contexts[name] = o
  return o
end

local default_set_opts = {
  on_conflict = function(key, old, new)
    return old
  end,
}

-- self:set
function M:set(key, value, opts)
  opts = vim.tbl_deep_extend('force', default_set_opts, opts or {})
  if self[key] then
    if predicate.is_function(opts.on_conflict) then
      self[key] = opts.on_conflict(key, self[k], value)
      return
    end
  end
  self[key] = value
end

-- self:get
function M:get(key)
  return self[key]
end

-- self:is_empty
function M:is_empty()
  return vim.tbl_isempty(self)
end

-- global context
M.g = M:new {}

-- get context
M.get_context = function(name)
  return contexts[name]
end

return M
