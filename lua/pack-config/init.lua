local packer = require('pack-config.packer')
local util = require('pack-config.util')
local log = require('pack-config.log')
local Profile = require('pack-config.profile')

local fn = util.fn
local pd = util.predicate
local tbl = util.tbl
local Set = util.set

local default_cfg = {
  loader = nil,
  loader_opts = {},
  scanner = nil,
  scanner_opts = {},
  parser = nil,
  parser_opts = {},
  block_list = {},
  env = {
    -- pack_getter
    pack = function(pack_name)
      return setmetatable({}, {
        __index = function(self, name)
          local v = packer.get_pack(pack_name)[name]
          self[name] = v
          return v
        end,
      })
    end,
  },
}

local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

local load = function(scan_paths)
  if pd.tbl_isempty(scan_paths) then
    log.warn('scan_paths is empty')
    return
  end

  local block_set = Set.from_list(cfg.block_list)

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
      local parsed_pack = cfg.parser.parse(pack)
      -- block_list filter
      if Set.contains(block_set, parsed_pack.name) then
        log.debug('block pack: ', parsed_pack.name)
      else
        valid_packs[parsed_pack.name] = parsed_pack
      end
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
M.setup = fn.once(function(opts)
  Profile.start('global', 'total')

  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)
  cfg.scanner = require('pack-config.scanner').with_default(cfg.scanner, true)
  cfg.parser = require('pack-config.parser').with_default(cfg.parser, true)
  cfg.loader = require('pack-config.loader').with_default(cfg.loader, true)

  cfg.parser.parse = fn.pipe(fn.with_env(cfg.env))(cfg.parser.parse)

  if pd.is_function(cfg.scanner.init) then
    cfg.scanner.init(cfg.scanner_opts)
  end
  if pd.is_function(cfg.parser.init) then
    cfg.parser.init(cfg.parser_opts)
  end
  if pd.is_function(cfg.loader.init) then
    cfg.loader.init(cfg.loader_opts)
  end
  packer.setup {
    loader = cfg.loader,
    env = cfg.env,
  }

  load(cfg.scan_paths)

  Profile.stop('global', 'total')
end)

return M
