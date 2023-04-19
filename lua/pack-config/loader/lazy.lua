local Const = require('pack-config.const')
local log = require('pack-config.log')
local util = require('pack-config.util')
local fn = util.fn
local tbl = util.tbl
local Set = util.set

local default_cfg = {
  auto_download = true,
  pack_self = false,
  outer_config = {},
}

local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'lazy'

M.exist = function()
  return pcall(require, 'lazy')
end

M.init = fn.once(function(opts)
  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)

  if not M.exist() then
    if cfg.auto_download then
      assert(
        util.download_pack {
          dist_dir = Const.path.init_pack,
          name = 'lazy',
          path = 'folke/lazy.nvim',
          prompt = 'Download lazy.nvim? [y/N]',
        },
        'Download lazy.nvim fail'
      )

      vim.opt.rtp:prepend(Const.path.init_pack .. 'lazy')
      -- vim.cmd([[qa]])
    else
      error('not find lazy.nvim', vim.log.levels.ERROR)
    end
  end

  -- some setup code
  local ok, _ = pcall(require, 'lazy')
  if not ok then
    error('not find lazy.nvim', vim.log.levels.ERROR)
  end
end, { notify = vim.log.levels.INFO })

--- @param pack table
---   {
---     '',
---     as = '',
---     branch = '',
---     commit = '',
---     tag = '',
---     pin = '',
---     ft = {},
---     opt = true,
---     run = function() end,
---     rtp = '',
---   },
local transform = function(pack)
  return {
    pack[1],
    dir = pack.dir,
    name = pack.as,
    branch = pack.branch,
    tag = pack.tag,
    commit = pack.commit,
    pin = pack.pin,
    ft = pack.ft,
    lazy = pack.opt,
    build = pack.run,
  }
end

--- 不支持的 opts 提示
local not_support_opts_tip = function(packs)
  local support_opts = Set.from_list {
    1,
    'dir',
    'as',
    'branch',
    'tag',
    'commit',
    'pin',
    'ft',
    'opt',
    'run',
  }
  local tips = Set.new()
  for _, pack in pairs(packs) do
    tips = tips and Set.different(Set.from_map(pack), support_opts)
  end
  if Set.is_notempty(tips) then
    log.warn('lazy.nvim not support opts', tips)
  end
end

--- @param packs table
---  pack = {'', as = '', ft = {}, opt = true, run = function() end}
M.load = function(packs)
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    error('not find lazy.nvim', vim.log.levels.ERROR)
  end

  packs = packs or {}

  if cfg.pack_self then
    table.insert(packs, { 'folke/lazy.nvim' })
  end

  not_support_opts_tip(packs)

  lazy.setup(
    tbl.tbl_map_filter(packs, function(pack)
      return transform(pack)
    end),
    cfg.outer_config
  )
end

return M
