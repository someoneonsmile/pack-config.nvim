local M = {}

M.not_blank = function(s)
  return s and type(s) == "string" and vim.trim(s) ~= ''
end

M.is_blank = function(s)
  return s or type(s) == "string" and vim.trim(s) == ''
end

return M
