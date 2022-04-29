local M = {}


local contexts = {}

function M:new(name, o)
  if contexts[name] then
    error(string.format('context_name: %s, has exist'))
  end
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  contexts[name] = o
  return o
end

local default_opts = {
  override = false
}

-- self:set
function M:set(key, value, opts)

    opts = vim.tbl_deep_extend('force', default_opts, opts or {})

    if config[key] then
        if opts.override then
            config[key] = value
            return true
        else
            return false
        end
    end

    config[key] = value
    return true
end


-- self:get
function M:get(key, opts)

    opts = vim.tbl_deep_extend('force', default_opts, opts or {})

    return self[key]
end


-- global context
M.g = M:new {}


-- get context
M.get_context = function(name)
  return contexts[name]
end


return M

