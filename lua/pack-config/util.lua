local log = require('pack-config.log')

local M = {}

M.answer = function(question, answers)
  answers = M.set:from_list(M.convert.to_table(answers or { 'y', 'yes' }))
  local input = vim.fn.input(question)
  return M.set.contains(answers, input)
end

-- ----------------------------------------------------------------------
--    - download -
-- ----------------------------------------------------------------------

-- @param pack
--  pack.dest_dir string dest dir
--  pack.prompt tip to user
--  pack.name
--  pack.path pack path
M.download_pack = function(pack)
  vim.fn.mkdir(pack.dist_dir, 'p')
  if not vim.endswith(pack.dist_dir, '/') then
    pack.dist_dir = pack.dist_dir .. '/'
  end
  if pack.prompt and M.answer(pack.prompt) then
    log.info(string.format('git clone https://github.com/%s.git %s', pack.path, pack.dist_dir .. pack.name))
    local out = vim.fn.system(
      string.format('git clone https://github.com/%s.git %s', pack.path, pack.dist_dir .. pack.name)
    )
    log.info(out)
    return vim.v.shell_error == 0
  end
  return false
end

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
