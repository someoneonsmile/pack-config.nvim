local M = {}

local no = 0

local function incr()
  no = no + 1
  return 'function' .. no
end

local conf = {}

M.once = function(f, opts)
  local key = opts and opts.prefix_name .. '/' .. opts.name or incr()

  return function(...)
    if conf[key] then
      if opts and opts.notify then
        vim.notify('once function call again', 'function key:', key)
      end
      return false
    end
    conf[key] = f
    return true, f(...)
  end
end

return M
