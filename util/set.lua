local M = {}

M.is_set = function(self)
  return getmetatable(self) == M
end

M.intersection = function(a, b)
  local result = M:new()
  for key in pairs(a) do
    if b[key] then
      result[key] = true
    end
  end
  return result
end

M.union = function(a, b)
  local result = M:new()
  for key in pairs(a) do
    result[key] = true
  end
  for key in pairs(b) do
    result[key] = true
  end
  return result
end

M.complement = function(a, b)
  local result = M:new()
  for key in pairs(a) do
    if b[key] == nil then
      result[key] = true
    end
  end
  for key in pairs(b) do
    result[key] = true
  end
  return result
end

M.__add = function(self, item)
  self[item] = true
  return self
end

M.__sub = function(self, item)
  self[item] = nil
  return self
end

M.__band = M.intersection

M.__bor = M.union

M.__bxor = M.complement

M.__concat = M.union

M.new = function(self)
  return setmetatable({}, self)
end

M.from_list = function(self, list)
  local s = {}
  for _, v in ipairs(list) do
    s[v] = true
  end
  return setmetatable(s, self)
end

M.from_map = function(self, map)
  local s = {}
  for k, _ in pairs(map) do
    s[k] = true
  end
  return setmetatable(s, self)
end

M.contains = function(self, item)
  return self[item] ~= nil
end

return M
