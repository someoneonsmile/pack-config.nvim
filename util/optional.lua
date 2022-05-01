local M = {}

M.__index = function(self, k)
  return self:dot(k)
end

M.__eq = function(self, other)
  return self.v == other.v
end

M.__tostring = function(self)
  return ('optional(%s)'):format(self.v)
end

M.__bor = function(lhs, rhs)
  return M.or_else(lhs, rhs)
end

M.is_option = function(self)
  return getmetatable(self) == M
end

M.new = function(self, v)
  return setmetatable({ v = v }, self)
end

M.empty = M:new()

M.is_empty = function(self)
  return self == M.empty
end

-- ----------------------------------------------------------------------
--    - dot -
-- ----------------------------------------------------------------------

M.dot = function(self, ...)
  local not_strings = vim.tbl_filter(function(it)
    return type ~= 'string'
  end, { ... })
  if not vim.tbl_isempty(not_strings) then
    error('args contains not string type')
  end
  local v = self.v
  if v == nil then
    return M.empty
  end
  for _, v_k in pairs { ... } do
    v = v[v_k]
    if v == nil then
      return M.empty
    end
  end
  return M:new(v)
end

M.dot_get = function(self, ...)
  return M.dot(self, ...).get()
end

-- ----------------------------------------------------------------------
--    - flatten -
-- ----------------------------------------------------------------------

M.flatten = function(self)
  local o = self
  while M.is_option(o) do
    o = o.v
  end
  return M:new(o)
end

M.flatten_get = function(self)
  local o = self
  while M.is_option(o) do
    o = o.v
  end
  return o
end

M.equal = function(self, other)
  if not M.is_option(self) or not M.is_option(other) then
    return false
  end
  return self.v == other.v
end

M.get = function(self)
  return self.v
end

M.or_else_get = function(self, v)
  return M.is_empty(self) and v or self.v
end

-- ----------------------------------------------------------------------
--    - or -
-- ----------------------------------------------------------------------

M.or_else = function(self, other)
  return M.is_empty(self) and other or self
end

return M
