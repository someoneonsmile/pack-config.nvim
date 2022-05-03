local M = {}

M.new = function(self, key_extractor, pre_extractor)
  local o = { key_extractor = key_extractor, pre_extractor = pre_extractor }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- ----------------------------------------------------------------------
--    - generator iterator -
-- ----------------------------------------------------------------------

-- @return name, pack
M.sort_iter = function(self, tbl)
  if tbl == nil or #tbl == 0 then
    return nil
  end
  local refs = {}
  local graph = {}
  local heads = {}
  for k, v in pairs(tbl) do
    local name = self.key_extractor(k, v)
    refs[name] = v
    graph[name] = graph[name] or { in_link = {}, out_link = {} }
    local pres = self.pre_extractor(v)
    if pres ~= nil and #pres > 0 then
      for _, pre in ipairs(pres) do
        graph[pre] = graph[pre] or { in_link = {}, out_link = {} }
        graph[name].in_link[pre] = true
        table.insert(graph[pre].out_link, name)
      end
    end
  end

  for name, links in pairs(graph) do
    if next(links.in_link) == nil then
      table.insert(heads, name)
    end
  end

  log.debug('sort_iter heads', heads)
  return function()
    local head = table.remove(heads)
    if head then
      for _, out_link in ipairs(graph[head].out_link) do
        graph[out_link].in_link[head] = nil
        if #graph[out_link].in_link == 0 then
          table.insert(heads, out_link)
        end
      end
      return head, refs[head]
    end
    if #graph > 0 then
      local name = next(graph)
      return name, refs[name]
    end
    return nil
  end
end

-- TODO: replace with sort_iter
M.sort = function(self, tbl)
  local refs = {}
  local graph = {}
  local heads = {}
  for k, v in pairs(tbl) do
    local name = self.key_extractor(k, v)
    refs[name] = v
    graph[name] = graph[name] or { in_link = {}, out_link = {} }
    local pres = self.pre_extractor(v)
    if pres ~= nil and #pres > 0 then
      for _, pre in ipairs(pres) do
        graph[pre] = graph[pre] or { in_link = {}, out_link = {} }
        graph[name].in_link[pre] = true
        table.insert(graph[pre].out_link, name)
      end
    end
  end

  for name, links in ipairs(graph) do
    if next(links.in_link) == nil then
      table.insert(heads, name)
    end
  end

  local result = {}
  while next(heads) ~= nil do
    local head = table.remove(heads)
    if head then
      for _, out_link in ipairs(graph[head].out_link) do
        graph[out_link].in_link[head] = nil
        if #graph[out_link].in_link == 0 then
          table.insert(heads, out_link)
        end
      end
      return table.insert(result, refs[head])
    end
    if #graph > 0 then
      local name = next(graph)
      table.insert(result, refs[name])
    end
    return nil
  end
  return result
end

return M
