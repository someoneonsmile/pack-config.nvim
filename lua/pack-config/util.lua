local M = {}

-- ----------------------------------------------------------------------
--    - update require load file -
-- ----------------------------------------------------------------------

M.loaded_udpate = function(pack_name, pack)
  local luacache = (_G.__luacache or {}).cache
  local paths = M.path.path_variant(pack_name)
  for _, path in pairs(paths) do
    package.loaded[path] = pack
    if luacache then
      luacache[path] = pack
    end
  end
end

M.lazy_require = function(require_path)
  return setmetatable({}, {
    __index = function(self, k)
      local v = require(require_path)[k]
      self[k] = v
      return v
    end,
  })
end

setmetatable(M, {
  __index = function(self, k)
    -- allow the sub model cross reference
    local v = M.lazy_require('pack-config.util.' .. k)
    self[k] = v
    return v
  end,
})
return M
