local M = {}

M.to_lua_path = function(root_path, absolute_paths)
  if not vim.endswith(root_path, '/') then
    root_path = root_path .. '/'
  end
  return vim.tbl_map(function(path)
    if path:sub(1, #root_path) ~= root_path then
      return
    end
    path = path:sub(#root_path + 1, -1)
    return path:gsub('%.[^.]*$', '')
  end, absolute_paths)
end

M.to_absolute_path = function(root_path, relative_paths)
  if not vim.endswith(root_path, '/') then
    root_path = root_path .. '/'
  end
  return vim.tbl_map(function(path)
    return root_path .. path
  end, relative_paths)
end

return M
