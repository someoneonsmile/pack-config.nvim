local Context = require('pack-config.context')
local M = {}


-- ----------------------------------------------------------------------
--    - once (avoid run more than once) -
-- ----------------------------------------------------------------------

local no = 0

local function incr()
  no = no + 1
  return 'function_' .. no
end


-- TODO: can move Context to global env ?
--
-- maybe can replace with context
-- local conf = {}
local conf = Context:new('pack-config.util.fn')

M.once = function(f, opts)
  opts = opts or {}
  local key = (opts.prefix_name or 'global') .. '/' .. (opts.name or incr())

  return function(...)
    if conf[key] then
      if opts.notify then
        vim.notify('once function call again. function key: ' .. key, opts.notify)
      end
      return false
    end
    conf[key] = f
    return true, f(...)
  end
end


-- ----------------------------------------------------------------------
--    - compatible unpack -
-- ----------------------------------------------------------------------

M.unpack = unpack or table.unpack


-- ----------------------------------------------------------------------
--    - filter function -
-- ----------------------------------------------------------------------

M.not_nil = function(it)
  return it ~= nil
end


M.is_nil = function(it)
  return it == nil
end


-- ----------------------------------------------------------------------
--    - map function -
-- ----------------------------------------------------------------------

M.orign = function(v)
  return v
end

M.first = function(tbl)
  return tbl[1]
end


-- ----------------------------------------------------------------------
--    - return a function that make the nil value to default_value -
-- ----------------------------------------------------------------------

M.with_default = function(default_value)
  return function(...)
    return M.unpack(vim.tbl_map(function(it) return it or default_value end, {...}))
  end
end


-- ----------------------------------------------------------------------
--    - return a function that map the table nil value to default_value -
-- ----------------------------------------------------------------------

M.tbl_with_default = function(default_value)
  return function(tbl)
    return vim.tbl_map(function(it) return it or default_value end, tbl or {})
  end
end


-- ----------------------------------------------------------------------
--    - avoid call on nil value -
-- ----------------------------------------------------------------------

M.dot_chain = function(tbl, ...)
  local not_strings = vim.tbl_filter(function(it) return type ~= 'string' end, {...})
  if not vim.tbl_isempty(not_strings) then
    error('args contains not string type')
  end
  local v = tbl
  for _, v_k in pairs({...}) do
    if v == nil then
      return nil
    end
    v = v[v_k]
  end
end


return M
