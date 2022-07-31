local Context = require('pack-config.context')
local Const = require('pack-config.const')
local Id = require('pack-config.util').id

local M = {}

M.unpack = unpack

-- ----------------------------------------------------------------------
--    - once (avoid run more than once) -
-- ----------------------------------------------------------------------

local auto_id = Id:new('fn_once')

-- use the context
-- maybe can replace with context
-- local conf = {}
local conf = Context:new(Const.util_fn_once_key)

M.once = function(f, opts)
  opts = opts or {}
  local key = (opts.prefix_name or 'global') .. '/' .. (opts.name or auto_id:inc())

  return function(...)
    if conf[key] then
      if opts.notify_fn then
        opts.notify_fn()
      end
      return false
    end
    conf[key] = f
    return true, f(...)
  end
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

M.last = function(tbl)
  return tbl[#tbl]
end

-- ----------------------------------------------------------------------
--    - return a function that make the nil value to default_value -
-- ----------------------------------------------------------------------

M.with_default = function(default_value)
  return function(...)
    local r = {}
    local l = select('#', ...)
    for i = 1, l do
      table.insert(r, select(i, ...) or default_value)
    end
    return M.unpack(r)
  end
end

-- ----------------------------------------------------------------------
--    - curry fn endwith () -
-- ----------------------------------------------------------------------

M.curry = function(fn, ...)
  local args = { ... }
  local function inner(...)
    if select('#', ...) == 0 then
      return fn(M.unpack(args))
    else
      vim.list_extend(args, { ... })
      return inner
    end
  end

  return inner
end

M.reduce = function(fn, acc, ...)
  if select('#', ...) == 0 then
    return acc
  end
  local result = acc
  for _, v in ipairs { ... } do
    result = fn(result, v)
  end
  return result
end

-- similar to reduce, use the first as init
M.fold = function(fn, ...)
  if select('#', ...) == 0 then
    return
  end
  local result = M.first { ... }
  for _, v in ipairs { select(2, ...) } do
    result = fn(result, v)
  end
  return result
end

M.pipe = function(...)
  if select('#', ...) == 0 then
    error('pipe requires at least one function')
  end
  return M.fold(function(pre, current)
    return function(...)
      return current(pre(...))
    end
  end, ...)
end

M.compose = function(...)
  M.pipe(M.reverse(...))
end

M.partial = function(fn, ...)
  local args = { ... }
  return function(...)
    fn(M.unpack(args), ...)
  end
end

M.filter = M.curry(function(fn, ...)
  local result = {}
  for _, v in ipairs { ... } do
    if fn(v) then
      table.insert(result, v)
    end
  end
  return result
end)

M.reject = M.curry(function(fn, ...)
  local result = {}
  for _, v in ipairs { ... } do
    if not fn(v) then
      table.insert(result, v)
    end
  end
  return result
end)

M.reverse = function(...)
  local result = {}
  local n = select('#', ...)
  for i, v in ipairs { ... } do
    result[n + 1 - i] = v
  end
  return result
end

M.take = M.curry(function(n, ...)
  if n < select('#', ...) then
    return ...
  end
  local r = { ... }
  r[n + 1] = nil
  return M.unpack(r)
end)

M.drop = M.curry(select)

M.take_last = M.curry(function(n, ...)
  local len = select('#', ...)
  if n >= len then
    return ...
  end
  return M.drop(len - n, ...)
end)

M.drop_last = M.curry(function(n, ...)
  local len = select('#', ...)
  if n >= len then
    return
  end
  return M.take(len - n, ...)
end)

-- ----------------------------------------------------------------------
--    - avoid call on nil value -
-- ----------------------------------------------------------------------

M.dot_chain = function(tbl, ...)
  local not_strings = vim.tbl_filter(function(it)
    return type ~= 'string'
  end, { ... })
  if not vim.tbl_isempty(not_strings) then
    error('args contains not string type')
  end
  local v = tbl
  for _, v_k in ipairs { ... } do
    if v == nil then
      return nil
    end
    v = v[v_k]
  end
end

-- ----------------------------------------------------------------------
--    - with_env -
-- ----------------------------------------------------------------------

M.with_env = function(env)
  env._G = _G
  env = setmetatable(env, { __index = _G })
  return function(fn)
    return setfenv(fn, env)
  end
end

-- ----------------------------------------------------------------------
--    - with_defer -
-- ----------------------------------------------------------------------

M.with_defer = function(timeout)
  return function(fn)
    return function(...)
      local args = { ... }
      vim.defer_fn(function()
        fn(M.unpack(args))
      end, timeout)
    end
  end
end

return M
