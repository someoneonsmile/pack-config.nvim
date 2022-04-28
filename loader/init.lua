local builtin_loaders = function()
  return {
    require('pack-config.loader.builtin.paq'),
    require('pack-config.loader.builtin.packer'),
  }
end


local available_builtin_loaders = function()
  return vim.tbl_filter(function(loader)
    return loader.exist()
  end, builtin_loaders())
end


local with_default = function(loader, report_error)
  if loader ~= nil and loader.exsit() then
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
    end
  else
    return available_loaders[1]
  end

end


local M = {
  builtin_loaders = builtin_loaders,
  available_builtin_loaders = available_builtin_loaders,
  with_default = with_default,
}

return M
