local log = require('pack-config.log')
local util = require('pack-config.util')
local Const = require('pack-config.const')
local fn = util.fn
local tbl = util.tbl
local Set = util.set

local default_cfg = {
  auto_download = true,
  pack_self = true,
  outer_config = {},
}

local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'packer'

M.exist = function()
  return pcall(require, 'packer')
end

M.init = fn.once(function(opts)
  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)

  if not M.exist() then
    if cfg.auto_download then
      assert(
        util.download_pack {
          dist_dir = Const.path.init_pack,
          name = 'packer',
          path = 'wbthomason/packer.nvim',
          prompt = 'Download packer.nvim? [y/N]',
        },
        'Download packer.nvim fail'
      )

      vim.opt.rtp:prepend(Const.path.init_pack .. 'packer')
      -- vim.cmd([[qa]])
    else
      error('not find packer.nvim', vim.log.levels.ERROR)
    end
  end

  -- some setup code
  local ok, packer = pcall(require, 'packer')
  if not ok then
    error('not find packer.nvim', vim.log.levels.ERROR)
  end

  packer.reset()
  packer.init(cfg.outer_config)
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
    as = pack.as,
    branch = pack.branch,
    tag = pack.tag,
    commit = pack.commit,
    lock = pack.pin,
    ft = pack.ft,
    opt = pack.opt,
    run = pack.run,
    rtp = pack.rtp,
  }
end

--- 不支持的 opts 提示
local not_support_opts_tip = function(packs)
  local support_opts = Set.from_list {
    1,
    'as',
    'branch',
    'tag',
    'commit',
    'pin',
    'ft',
    'opt',
    'run',
    'rtp',
  }
  local tips = Set.new()
  for _, pack in pairs(packs) do
    tips = tips and Set.different(Set.from_map(pack), support_opts)
  end
  if Set.is_notempty(tips) then
    log.warn('packer not support opts', tips)
  end
end

--- @param packs table
---  pack = {'', as = '', ft = {}, opt = true, run = function() end}
M.load = function(packs)
  local ok, packer = pcall(require, 'packer')
  if not ok then
    error('not find packer.nvim', vim.log.levels.ERROR)
  end

  packs = packs or {}

  if cfg.pack_self then
    table.insert(packs, { 'wbthomason/packer.nvim' })
  end

  not_support_opts_tip(packs)

  packer.startup(function(use)
    for _, pack in ipairs(packs) do
      use(transform(pack))
    end
  end)
end

return M
