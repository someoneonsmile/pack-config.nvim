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
    error(string.format('context_name: %s, has exist', name))
  end
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  contexts[name] = o
  return o
end

local default_set_opts = {
  on_conflict = function(key, old, new)
    return new
  end,
}

-- self:set
function M:set(key, value, opts)
  opts = vim.tbl_deep_extend('keep', opts or {}, default_set_opts)
  if self[key] then
    if type(opts.on_conflict) == 'function' then
      self[key] = opts.on_conflict(key, self[key], value)
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
M.g = M:new('')

-- get context
M.get_context = function(name)
  return contexts[name]
end

return M
