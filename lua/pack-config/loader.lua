local convert = require('pack-config.util.convert')
local builtin_loaders = function()
  return {
    require('pack-config.loader.packer'),
    require('pack-config.loader.paq'),
  }
end

local available_builtin_loaders = function()
  return vim.tbl_filter(function(loader)
    return convert.to_bool(loader.exist)
  end, builtin_loaders())
end

local with_default = function(loader, report_error)
  if loader ~= nil then
    if not loader.exist() and report_error then
      error(string.format('the loader not exist, %s', loader.name))
    end
    return loader
  end
  local loaders = builtin_loaders()
  local loader_names = vim.tbl_map(function(it)
    return it.name
  end, loaders)

  local available_loaders = available_builtin_loaders()

  if vim.tbl_isempty(available_loaders) then
    if report_error then
      error(string.format(
        [[there is no pack loader available here.
        if use the builtin loader please make sure to download them before
        builtin_loaders: %s]],
        table.concat(loader_names, ', ')
      ))
    end
    return loaders[1]
  else
    return available_loaders[1]
  end
end

local M = setmetatable({
  builtin_loaders = builtin_loaders,
  available_builtin_loaders = available_builtin_loaders,
  with_default = with_default,
}, {
  __index = function(self, k)
    local v = require('pack-config.loader.' .. k)
    self[k] = v
    return v
  end,
})

return M
