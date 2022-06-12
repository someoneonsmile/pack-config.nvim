local packer = require('pack-config.packer')
local util = require('pack-config.util')
local log = require('pack-config.log')

local default_cfg = {
  loader = nil,
  loader_opts = {},
  scanner = nil,
  scanner_opts = {},
  parser = nil,
  parser_opts = {},
  env = {
    -- pack_getter
    pack = function(pack_name)
      return packer.get_pack(pack_name)
    end,
  },
}

local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

local load = function(scan_paths)
  if util.tbl_isempty(scan_paths) then
    log.warn('scan_paths is empty')
    return
  end

  -- scan lua file
  local pack_paths = cfg.scanner.scan(scan_paths)

  -- filter valid pack
  local valid_packs = {}
  for _, pack_path in ipairs(pack_paths) do
    local ok, pack = pcall(dofile, pack_path, 'bt')
    if not ok then
      log.error('load lua file failed, path = ' .. pack_path, pack)
    elseif not cfg.parser.is_pack(pack) then
      log.error('not a pack. path =', pack_path)
    else
      valid_packs[pack.name] = cfg.parser.parse(pack)
    end
  end

  -- pack istall and config
  packer.regist(valid_packs)
  packer.done()
end

-- @param opts
--  opts.scanner: scanner builtin or custom
--  opts.scanner_opts: control the scanner init action
--  opts.loader: loader builtin or custom
--  opts.loader_opts: control the loader init action
--  opts.env: env to pack setup/config
M.setup = util.fn.once(function(opts)
  cfg = util.deep_merge_opts(default_cfg, opts)
  cfg.scanner = require('pack-config.scanner').with_default(cfg.scanner, false)
  cfg.parser = require('pack-config.parser').with_default(cfg.parser, false)
  cfg.loader = require('pack-config.loader').with_default(cfg.loader, false)
  if type(cfg.scanner.init) == 'function' then
    cfg.scanner.init(cfg.scanner_opts)
  end
  if type(cfg.parser.init) == 'function' then
    cfg.parser.init(cfg.parser_opts)
  end
  if type(cfg.loader.init) == 'function' then
    cfg.loader.init(cfg.loader_opts)
  end
  packer.setup {
    loader = cfg.loader,
    env = cfg.env,
  }
  load(cfg.scan_paths)
end)

return M
