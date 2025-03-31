local packer = require('pack-config.packer')
local util = require('pack-config.util')
local log = require('pack-config.log')
local Profile = require('pack-config.profile')

local fn = util.fn
local pd = util.predicate
local tbl = util.tbl
local Set = util.set
local enhance = util.enhance

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
  Profile.start('pack-config', 'load scan')
  local pack_paths = cfg.scanner.scan(scan_paths)
  Profile.stop('pack-config', 'load scan')

  -- filter valid pack
  Profile.start('pack-config', 'load parse')
  local valid_packs = {}
  for _, pack_path in ipairs(pack_paths) do
    local ok, pack = enhance.dofile(pack_path, 'bt', cfg.env)
    if not ok then
      log.error('load lua file failed, path = ' .. pack_path, pack)
    elseif not cfg.parser.is_pack(pack) then
      log.error('not a pack. path = ', pack_path)
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
  Profile.stop('pack-config', 'load parse')

  -- pack istall and config
  Profile.start('pack-config', 'load regist')
  packer.regist(valid_packs)
  Profile.stop('pack-config', 'load regist')

  Profile.start('pack-config', 'load done')
  packer.done()
  Profile.stop('pack-config', 'load done')
end

-- @param opts
--  opts.scanner: scanner builtin or custom
--  opts.scanner_opts: control the scanner init action
--  opts.loader: loader builtin or custom
--  opts.loader_opts: control the loader init action
--  opts.env: env to pack setup/config
M.setup = fn.once(function(opts)
  Profile.start('pack-config', 'total')

  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)
  cfg.env.require = enhance.with_env_require(cfg.env)
  cfg.env.R = enhance.with_env_require(cfg.env)
  -- env
  setmetatable(cfg.env, {
    __index = _G,
    -- __newindex = function(table, key, value)
    --   rawset(_G, key, value)
    -- end,
    __newindex = _G,
  })

  Profile.start('pack-config', 'init')
  cfg.scanner = require('pack-config.scanner').with_default(cfg.scanner, false)
  cfg.parser = require('pack-config.parser').with_default(cfg.parser, false)
  cfg.loader = require('pack-config.loader').with_default(cfg.loader, false)

  if pd.is_function(cfg.scanner.init) then
    cfg.scanner.init(cfg.scanner_opts)
  end
  if pd.is_function(cfg.parser.init) then
    cfg.parser.init(cfg.parser_opts)
  end
  if pd.is_function(cfg.loader.init) then
    cfg.loader.init(cfg.loader_opts)
  end
  Profile.stop('pack-config', 'init')

  Profile.start('pack-config', 'load total')
  packer.setup {
    loader = cfg.loader,
  }
  load(cfg.scan_paths)
  Profile.stop('pack-config', 'load total')

  Profile.stop('pack-config', 'total')
end)

M.version = '0.8.0'

return M
