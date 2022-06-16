local log = require('pack-config.log')
local util = require('pack-config.util')
local fn = util.fn

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
  cfg = util.deep_merge_opts(default_cfg, opts)

  if not M.exist() then
    if cfg.auto_download then
      assert(
        util.download_pack {
          dist_dir = vim.fn.stdpath('data') .. '/site/pack/init/start/',
          name = 'packer',
          path = 'wbthomason/packer.nvim',
          prompt = 'Download packer.nvim ? (y for yes)',
        },
        'Download packer.nvim fail'
      )

      vim.cmd([[qa]])
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

-- @param pack
--   {
--     '',
--     as = '',
--     branch = '',
--     rtp = '',
--     tag = '',
--     pin = '',
--     ft = {},
--     opt = true,
--     run = function() end,
--   },
local transform = function(pack)
  return {
    pack[1],
    as = pack.as,
    branch = pack.branch,
    tag = pack.tag,
    lock = pack.pin,
    ft = pack.ft,
    opt = pack.opt,
    run = pack.run,
    rtp = pack.rtp,
  }
end

-- 不支持的 opts 提示
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

-- @param packs table
--  pack = {'', as = '', ft = {}, opt = true, run = function() end}
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
