local M = {}

M.__index = M

M.is_set = function(self)
  return getmetatable(self) == M
end

-- 交集
M.intersection = function(a, b)
  local result = M:new()
  for key in pairs(a) do
    if b[key] then
      result[key] = true
    end
  end
  return result
end

-- 并集
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

-- 补集
M.complement = function(a, b)
  local result = M:new()
  for key in pairs(a) do
    if b[key] == nil then
      result[key] = true
    end
  end
  for key in pairs(b) do
    if a[key] == nil then
      result[key] = true
    end
  end
  return result
end

-- 差集
M.different = function(a, b)
  local result = M:new()
  for key in pairs(a) do
    if b[key] == nil then
      result[key] = true
    end
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

-- 交
M.__band = M.intersection

-- 并
M.__bor = M.union

-- 补
M.__bxor = M.complement

-- 并
M.__concat = M.union

-- 右差
M.__shr = M.different

-- 左差
M.__shl = function(a, b)
  M.different(b, a)
end

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

M.is_empty = function(self)
  return next(self) == nil
end

M.is_notempty = function(self)
  return next(self) ~= nil
end

return M
