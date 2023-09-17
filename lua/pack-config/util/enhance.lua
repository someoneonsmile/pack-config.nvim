local util = require('pack-config.util')
local fn = util.fn

local M = {}

---@param file_name string
---@param mode?     loadmode
---@param env?      table
---@return boolean?  status
---@return string?  result
---@nodiscard
M.dofile = function(file_name, mode, env)
  local with_env = fn.with_env(env)
  local f = assert(loadfile(file_name, mode or 'bt'))
  return assert(pcall(with_env(f)))
end

return M
