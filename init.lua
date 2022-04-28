local packer = require('pack-config.packer')

local scanner
local loader

local M = {}


M.setup = function (opts)
  scanner = require('pack-config.scanner').with_default(opts and opts.scanner, true)
  loader = require('pack-config.loader').with_default(opts and opts.loader, true)
end


local to_absolute_path = function (root_path, relative_paths)
  if not vim.endswith(root_path, '/') then
    root_path = root_path .. '/'
  end
  return vim.tbl_map(function(path) return root_path .. path end, relative_paths)
end


local to_lua_path = function (root_path, absolute_paths)
  if not vim.endswith(root_path, '/') then
    root_path = root_path .. '/'
  end
  return vim.tbl_map(function(path)
    if path:sub(1, #root_path) == root_path then
      path = path:sub(#root_path + 1, -1)
    end
    return path:gsub('%.[^.]*$', '')
  end, absolute_paths)
end


M.config_packs = function(scan_paths)
  -- TODO:  use plenary.path refact the code
  local root_path = vim.fn.stdpath('config') .. '/'

  local opts = {
    pattern = '.lua',
    extension = 'lua',
  }

  -- scan lua file
  scan_paths = to_absolute_path(root_path, scan_paths)
  local pack_paths = scanner.scan(scan_paths, opts)
  pack_paths = to_lua_path(root_path, pack_paths)
  vim.pretty_print(pack_paths)


  -- filter valid pack
  local valid_packs = {}
  for _, pack_path in ipairs(pack_paths) do
    local ok, pack = pcall(require, pack_path)
    if ok and packer.is_pack(pack) then
      valid_packs[pack.name or pack_path] = pack
    end
  end

  -- pack istall and config
  packer.setup({
    loader = loader
  })
  packer.regist(valid_packs)
  packer.done()

end

return M
