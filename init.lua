local packer = require('pack-config.packer')
local util   = require('pack-config.util')

local scanner
local loader

local M = {}


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


-- TODO: 支持完整路径
local load = function(scan_paths)
  -- TODO:  use plenary.path refact the code
  local root_path = vim.fn.stdpath('config') .. '/'

  local opts = {
    pattern = '.lua',
    extension = 'lua',
  }

  -- scan lua file
  scan_paths = to_absolute_path(root_path, scan_paths)
  local pack_paths = scanner.scan(scan_paths, opts)
  pack_paths = to_lua_path(root_path .. 'lua/', pack_paths)


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


-- @param opts
--  opts.scanner: scanner builtin or custom
--  opts.scanner_opts: control the scanner init action
--  opts.loader: loader builtin or custom
--  opts.loader_opts: control the loader init action
M.setup = util.fn.once(function (opts)
  opts = util.deep_merge_opts({
    loader_opts = {
      auto_download = true,
      package = nil,
    },
  }, opts)
  scanner = require('pack-config.scanner').with_default(opts and opts.scanner, false)
  loader = require('pack-config.loader').with_default(opts and opts.loader, false)
  scanner.init(opts.scanner_opts)
  loader.init(opts.loader_opts)

  load(opts.scan_paths)

end)


return M
