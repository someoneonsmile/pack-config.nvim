local log = require('pack-config.log')
local util = require('pack-config.util')
local sorter = util.sort
local M = {}

M.new = function(self, key_extractor, pre_extractor)
  local o = { key_extractor = key_extractor, pre_extractor = pre_extractor }
  setmetatable(o, self)
  self.__index = self
  return o
end

local function print_circle_graph(graph)
  if next(graph) == nil then
    return
  end
  log.warn('Circle detected, graph:', graph)
  local paths = {}
  local tbl_index = function(tbl, value)
    for i, v in ipairs(tbl) do
      if v == value then
        return i
      end
    end
  end
  local tbl_slice = function(tbl, s, e)
    local r = {}
    for i = math.max(1, s), math.min(#tbl, e), 1 do
      table.insert(r, tbl[i])
    end
    return r
  end
  -- TODO:
  local function print_circle(name)
    -- TODO: name can be nil
    local i = tbl_index(paths, name)
    if i then
      log.warn('Circle detected, path:', table.concat(tbl_slice(paths, i, #paths), ' -> '))
      return
    end
    table.insert(paths, name)
    for _, v in ipairs(graph[name].out_link) do
      print_circle(v)
    end
    table.remove(paths)
  end

  print_circle(next(graph))
end

-- ----------------------------------------------------------------------
--    - generator iterator -
-- ----------------------------------------------------------------------

M.sort_iter = function(self, tbl)
  if tbl == nil or #tbl == 0 then
    return nil
  end
  local refs = {}
  local graph = {}
  local heads = {}
  local origin_orders = {}

  -- 构建依赖图
  for i, v in ipairs(tbl) do
    local name = self.key_extractor(i, v)
    refs[name] = v
    origin_orders[name] = i
    graph[name] = graph[name] or { in_link = {}, out_link = {} }
    local pres = self.pre_extractor(v)
    -- 如果依赖已经在前面了, 直接去掉
    pres = vim.tbl_filter(function(pre)
      return refs[pre] == nil
    end, pres or {})
    if #pres > 0 then
      for _, pre in ipairs(pres) do
        graph[pre] = graph[pre] or { in_link = {}, out_link = {} }
        graph[name].in_link[pre] = true
        table.insert(graph[pre].out_link, name)
      end
    else
      table.insert(heads, name)
    end
  end

  local circle_tiped = false

  -- @return name, pack
  return function()
    if next(heads) ~= nil then
      local head = table.remove(heads, 1)
      for _, out_link in ipairs(graph[head].out_link) do
        graph[out_link].in_link[head] = nil
        if next(graph[out_link].in_link) == nil then
          table.insert(heads, out_link)
          sorter.sort(heads, function(it)
            return origin_orders[it]
          end)
        end
      end
      graph[head] = nil
      return head, refs[head]
    end
    if next(graph) ~= nil then
      if not circle_tiped then
        circle_tiped = true
        print_circle_graph(graph)
      end
      local name = next(graph)
      graph[name] = nil
      return name, refs[name]
    end
  end
end

-- TODO: maybe can replace with sort_iter
M.sort = function(self, tbl)
  local refs = {}
  local graph = {}
  local heads = {}
  local origin_orders = {}

  -- 构建依赖图
  for i, v in ipairs(tbl) do
    local name = self.key_extractor(i, v)
    refs[name] = v
    origin_orders[name] = i
    graph[name] = graph[name] or { in_link = {}, out_link = {} }
    local pres = self.pre_extractor(v)
    -- 如果依赖已经在前面了, 直接去掉
    pres = vim.tbl_filter(function(pre)
      return refs[pre] == nil
    end, pres or {})
    if #pres > 0 then
      for _, pre in ipairs(pres) do
        graph[pre] = graph[pre] or { in_link = {}, out_link = {} }
        graph[name].in_link[pre] = true
        table.insert(graph[pre].out_link, name)
      end
    else
      table.insert(heads, name)
    end
  end

  local result = {}
  while next(heads) ~= nil do
    local head = table.remove(heads, 1)
    for _, out_link in ipairs(graph[head].out_link) do
      graph[out_link].in_link[head] = nil
      if next(graph[out_link].in_link) == nil then
        table.insert(heads, out_link)
        sorter.sort(heads, function(it)
          return origin_orders[it]
        end)
      end
    end
    graph[head] = nil
    table.insert(result, refs[head])
  end
  if next(graph) ~= nil then
    print_circle_graph(graph)
    for name, _ in pairs(graph) do
      table.insert(result, refs[name])
    end
  end
  return result
end

return M
