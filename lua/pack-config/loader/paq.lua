local log = require('pack-config.log')
local util = require('pack-config.util')
local Const = require('pack-config.const')
local fn = util.fn
local tbl = util.tbl
local Set = util.set

local default_cfg = {
  auto_download = true,
  pack_self = true,
  package = 'paqs',
}

local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'paq'

M.exist = function()
  return pcall(require, 'paq')
end

M.init = fn.once(function(opts)
  cfg = tbl.tbl_force_deep_extend(default_cfg, opts)

  if not M.exist() then
    if cfg.auto_download then
      assert(
        util.download_pack {
          dist_dir = Const.path.init_pack,
          name = 'paq',
          path = 'savq/paq-nvim',
          prompt = 'Download paq-nvim? [y/N]',
        },
        'Download paq fail'
      )

      vim.opt.rtp:prepend(Const.path.init_pack .. 'pqa')
      -- vim.cmd([[qa]])
    else
      error('not find paq-nvim')
    end
  end

  -- some setup code
  local ok, paq = pcall(require, 'paq')
  if not ok then
    error('not find savq/paq-nvim')
  end
  paq:setup {
    path = vim.fn.stdpath('data') .. '/site/pack/' .. cfg.package .. '/',
  }
end)

--- @param pack
---   {
---     '',
---     as = '',
---     branch = '',
---     tag = '',
---     pin = '',
---     ft = {},
---     opt = true,
---     rtp = '',
---     run = function() end,
---   },
local transform = function(pack)
  return {
    pack[1],
    as = pack.as,
    branch = pack.branch,
    opt = pack.opt,
    pin = pack.pin,
    run = pack.run,
  }
end

--- 不支持的 opts 提示
local not_support_opts_tip = function(packs)
  local support_opts = Set.from_list {
    1,
    'as',
    'branch',
    'pin',
    'opt',
    'run',
  }
  local tips = Set.new()
  for _, pack in pairs(packs) do
    tips = tips .. Set.different(Set.from_map(pack), support_opts)
  end
  if Set.is_notempty(tips) then
    log.warn('paq not support opts', tips)
  end
end

--- @param packs table
---  pack = {'', as = '', ft = {}, opt = true, run = function() end}
M.load = function(packs)
  local ok, paq = pcall(require, 'paq')
  if not ok then
    error('not find paq-nvim')
  end

  packs = packs or {}

  if cfg.pack_self then
    table.insert(packs, { 'savq/paq-nvim' })
  end
  not_support_opts_tip(packs)
  paq(vim.tbl_map(transform, packs))
end

return M
