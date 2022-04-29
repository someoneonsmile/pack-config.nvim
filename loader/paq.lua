local util = require('pack-config.util')
local fn = require('pack-config.util.fn')

local M = {}

M.name = 'paq'


M.exist = function()
  return pcall(require, 'paq')
end

local cfg = {
  auto_download = true,
  pack_self = true,
  package = nil,
}

M.init = fn.once(function (opts)

  cfg = util.deep_merge_opts(cfg, opts)

  if not M.exist() then
    if cfg.auto_download then
      util.download_pack({
        dist_dir = vim.fn.stdpath('data') .. '/site/pack/init/start/',
        name = 'paq',
        path = 'savq/paq-nvim',
        prompt = 'Download paq-nvim ? (y for yes)',
      })
      vim.cmd [[qa]]
    else
      error('not find paq-nvim')
    end
  end

  -- some setup code
  local ok, paq = pcall(require, 'paq')
  if not ok then
    error('not find paq-nvim')
  end
  paq:setup({
    path = vim.fn.stdpath('data') .. '/site/pack/' .. (cfg.package or 'paqs') .. '/'
  })

end)


-- @param pack
--   {
--     '',
--     as = '',
--     branch = '',
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
    opt = pack.opt,
    pin = pack.pin,
    run = pack.run,
  }
end


-- @param packs table
--  pack = {'', as = '', ft = {}, opt = true, run = function() end}
M.load = function(packs)
  local ok, paq = pcall(require, 'paq')
  if not ok then
    error('not find paq-nvim')
  end

  packs = packs or {}

  if cfg.pack_self then
    table.insert(packs, {'savq/paq-nvim'})
  end

  paq(vim.tbl_map(transform, packs))
end

return M
