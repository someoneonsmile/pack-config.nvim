local util = require('pack-config.util')
local pred = util.predicate

local M = {}

---@param file_name string
---@param mode?     loadmode
---@param env?      table
---@return boolean?  status
---@return string?  result
---@nodiscard
-- M.dofile = function(file_name, mode, env)
--   local with_env = fn.with_env(env)
--   local f = assert(loadfile(file_name, mode or 'bt'))
--   return assert(pcall(with_env(f)))
-- end
M.dofile = function(file_name, mode, env)
  local f = assert(loadfile(file_name, mode or 'bt', env))
  return assert(pcall(f))
end

M.require = function(moudle_name, env)
  local loaded = package.loaded[moudle_name]
  if loaded then
    return loaded
  end
  local custom_loader = function(modname)
    local ret = vim.loader.find(modname)[1]
    if ret then
      local chunk, err = loadfile(ret.modpath, 'bt', env)
      return chunk or error(err)
    end
    return '\ncache_loader: module ' .. modname .. ' not found'
  end
  local chunk = custom_loader(moudle_name)
  if pred.is_type({ 'function' }, chunk) then
    local r = chunk()
    package.loaded[moudle_name] = r
    return r
  end
  return _G.require(moudle_name)
end

-- TODO: remove, replace with curry
M.with_env_require = function(env)
  return function(moudle_name)
    return M.require(moudle_name, env)
  end
end

return M
