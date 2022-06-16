local M = {}

M.is_function = function(f)
  return type(f) == 'function'
end

return M
