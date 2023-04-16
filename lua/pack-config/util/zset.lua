local Set = require('pack-config.util').set
local M = {}

M.is_set = function(self)
  return getmetatable(self) == M
end

M.intersection = function(a, b)
  local result = M:new()
  for _, v in ipairs(a) do
    if b.contains(v) then
      result = result + v
    end
  end
  return result
end

M.union = function(a, b)
  local result = M:new()
  for _, v in ipairs(a) do
    result = result + v
  end
  for _, v in ipairs(b) do
    result = result + v
  end
  return result
end

M.complement = function(a, b)
  local result = M:new()
  for _, v in pairs(a) do
    if not b.contains(v) then
      result = result + v
    end
  end
  for _, v in ipairs(b) do
    result = result + v
  end
  return result
end

M.__add = function(self, item)
  if self.s.contains(item) then
    return self
  end
  table.insert(self, item)
  self.s = self.s + item
  return self
end

M.__sub = function(self, item)
  if not self.s.contains(item) then
    return self
  end
  local len = #self
  local l = 1
  local find = false
  for r = 1, len, 1 do
    if find then
      self[l] = self[r]
    end
    if self[r] ~= item then
      l = l + 1
    else
      find = true
    end
  end
  return self
end

M.__band = M.intersection

M.__bor = M.union

M.__bxor = M.complement

M.__concat = M.union

M.__ipairs = function(tbl)
  -- Iterator function
  local function stateless_iter(tbl, i)
    -- Implement your own index, value selection logic
    i = i + 1
    local v = tbl[i]
    if nil ~= v then
      return i, v
    end
  end

  -- return iterator function, table, and starting point
  return stateless_iter, tbl, 0
end

M.__pairs = M.__ipairs

M.new = function()
  return setmetatable({ s = Set.new() }, M)
end

M.from_list = function(list)
  local z = M.new()
  for _, v in ipairs(list) do
    if not Set.contains(z.s, v) then
      table.insert(z, v)
      z.s = z.s + v
    end
  end
  return z
end

M.contains = function(self, item)
  return Set.contains(self.s, item)
end

return M
