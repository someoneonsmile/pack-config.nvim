local log = require('pack-config.log')
local util = require('pack-config.util')
local fn = util.fn
local tbl = util.tbl

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
      util.download_pack {
        dist_dir = vim.fn.stdpath('data') .. '/site/pack/init/start/',
        name = 'paq',
        path = 'savq/paq-nvim',
        prompt = 'Download paq-nvim? [y/N]',
      }
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
  local not_support_opts = {
    ft = true,
    rtp = true,
  }
  local tips = {}
  for k in pairs(packs) do
    if not_support_opts[k] ~= nil then
      tips[k] = true
    end
  end
  if not vim.tbl_isempty(tips) then
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
