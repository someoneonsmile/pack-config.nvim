local log = require('pack-config.log')
local util = require('pack-config.util')
local fn = util.fn
local tbl = util.tbl

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
          dist_dir = vim.fn.stdpath('data') .. '/site/pack/init/start/',
          name = 'lazy',
          path = 'folke/lazy.nvim',
          prompt = 'Download lazy.nvim? [y/N]',
        },
        'Download lazy.nvim fail'
      )

      vim.cmd([[qa]])
    else
      error('not find lazy.nvim', vim.log.levels.ERROR)
    end
  end

  -- some setup code
  local ok, lazy = pcall(require, 'lazy')
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
  local not_support_opts = {}
  local tips = {}
  for k in pairs(packs) do
    if not_support_opts[k] ~= nil then
      tips[k] = true
    end
  end
  if not vim.tbl_isempty(tips) then
    log.warn('packer not support opts', tips)
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

  lazy.startup(
    tbl.tbl_map_filter(packs, function(pack)
      return transform(pack)
    end),
    cfg.outer_config
  )
end

return M
