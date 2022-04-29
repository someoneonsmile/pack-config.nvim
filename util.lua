local M = {}

-- ----------------------------------------------------------------------
--    - table op -
-- ----------------------------------------------------------------------

M.tbl_distinct = function(tbl)
  local see = {}
  for k, v in pairs(tbl) do
    if see[k] == nil then
      see[k] = v
    end
  end
  return see
end

M.tbl_isempty = function(tbl)
  return tbl == nil or vim.tbl_isempty(tbl)
end


M.tbl_notempty = function(tbl)
  return not M.tbl_isempty(tbl)
end

M.tbl_filter_map = function(tbl, filters, maps)
  tbl = M.confirm_table(tbl)
  filters = M.confirm_table(filters)
  maps = M.confirm_table(maps)

  return not M.tbl_isempty(tbl)
end

M.deep_merge_opts = function(default_opts, opts)
  default_opts = default_opts or {}
  opts = opts or {}
  return vim.tbl_deep_extend('force', default_opts, opts)
end


M.merge_opts = function(default_opts, opts)
  default_opts = default_opts or {}
  opts = opts or {}
  return vim.tbl_extend('force', default_opts, opts)
end


M.tbl_force_extend = function(...)
  return vim.tbl_extend('force', M.fn.with_default({})(...))
end


M.tbl_force_deep_extend = function(...)
  return vim.tbl_deep_extend('force', M.with_default({})(...))
end


M.confirm_table = function(tbl)
  if type(tbl) == 'nil' or type(tbl) == 'table' then
    return tbl
  end
  return { tbl }
end


M.function_or_table = function(tbl, error_arg_name)
  if type(tbl) == 'function' then
    return { tbl }
  elseif type(tbl) == 'table' then
    return tbl
  end

  if error_arg_name ~= nil then
    error('%s require function or table', error_arg_name)
  end
  return tbl
end


M.string_or_table = function(tbl, error_arg_name)
  if type(tbl) == 'string' then
    return { tbl }
  elseif type(tbl) == 'table' then
    return tbl
  end

  if error_arg_name ~= nil then
    error('%s require string or table', error_arg_name)
  end
  return tbl
end


-- ----------------------------------------------------------------------
--    - list op -
-- ----------------------------------------------------------------------

M.list_extend = function(dst, ...)
  for _, src in pairs({ ... }) do
    vim.list_extend(dst, src)
  end
  return dst
end

M.list_distinct = function(key_extractor, list)
  local see = {}
  local result = {}
  for _, v in pairs(list) do
    local k = key_extractor(v)
    if not see[k] then
      see[k] = true
      table.insert(result, v)
    end
  end
  return result
end


M.list_to_map = function(list, key_extractor, value_extractor)
  if list == nil then
    return {}
  end

  local result_map = {}
  for _, v in ipairs(list) do
    local k = key_extractor(v)
    if k ~= nil and result_map[k] == nil then
      result_map[k] = value_extractor(v)
    end
  end
  return result_map
end

-- ----------------------------------------------------------------------
--    - deprecated: {} table will ignore nil -
-- ----------------------------------------------------------------------

M.filter_nil = function(...)
  return M.fn.unpack(vim.tbl_filter(M.fn.not_nil, { ... }))
end


M.answer = function(question)
  local answer = vim.fn.input(question)
  return answer == 'y' or answer == 'yes'
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
    vim.notify(string.format('git clone https://github.com/%s.git %s', pack.path, pack.dist_dir .. pack.name))
    local out = vim.fn.system(
      string.format('git clone https://github.com/%s.git %s', pack.path, pack.dist_dir .. pack.name)
    )
    vim.notify(out)
    return vim.v.shell_error == 0
  end
  return false
end


setmetatable(M, {
  __index = function(self, k)
    local v = require('pack-config.util.' .. k)
    self[k] = v
    return v
  end,
})
return M
