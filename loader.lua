local builtin_loaders = function()
  return {
    require('pack-config.loader.paq'),
    require('pack-config.loader.packer'),
  }
end


local available_builtin_loaders = function()
  return vim.tbl_filter(function(loader)
    return loader.exist()
  end, builtin_loaders())
end


local with_default = function(loader, report_error)
  if loader ~= nil and loader.exist() then
    return loader
  end
  local loaders = builtin_loaders()
  local loader_names = vim.tbl_map(function(it) return it.name end, loaders)

  local available_loaders = available_builtin_loaders()

  if vim.tbl_isempty(available_loaders) then
    if report_error then
      error(string.format([[there is no pack loader available here.
        if use the builtin loader please make sure to download them before
        builtin_loaders: %s]], table.concat(loader_names, ', ')))
    elseif loader ~= nil then
      return loader
    else
      return loaders[1]
    end
  else
    return available_loaders[1]
  end

end


local M = setmetatable({
  builtin_loaders = builtin_loaders,
  available_builtin_loaders = available_builtin_loaders,
  with_default = with_default,
}, {
  __index = function (self, k)
    local v = require('pack-config.loader.' .. k)
    self[k] = v
    return v
  end,
})

return M
