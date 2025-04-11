local uv = vim.uv

local M = {}

M.type = function(path)
  return uv.fs_stat(path).type
end

M.walk_dir = function(path, callback, max_deep)
  if max_deep ~= nil and max_deep < 1 then
    return
  end
  local handle = uv.fs_scandir(path)
  while handle do
    local name, t = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    local full_name = path .. '/' .. name
    callback(full_name, name, t)
    if M.type(full_name) == 'directory' then
      M.walk_dir(full_name, callback, max_deep - 1)
    end
  end
end

M.walk_dir_async = function(path, callback, max_deep)
  if max_deep ~= nil and max_deep < 1 then
    return
  end
  local function create_read_dir(base_path)
    return function(err, fd)
      if err then
        return
      end
      while fd do
        local name, t = uv.fs_scandir_next(fd)
        if not name then
          break
        end
        local full_name = base_path .. '/' .. name
        callback(full_name, name, t)
        if M.type(full_name) == 'directory' then
          uv.fs_scandir(full_name, create_read_dir(full_name), max_deep - 1)
        end
      end
    end
  end

  uv.fs_scandir(path, create_read_dir(path))
end

return M
