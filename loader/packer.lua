local util = require('pack-config.util')
local fn = require('pack-config.util.fn')

local M = {}

M.name = 'packer'

M.exist = function()
  return pcall(require, 'packer')
end

local cfg = {
  auto_download = true,
  pack_self = true,
  package = nil,
}

M.init = fn.once(function(opts)
  cfg = util.deep_merge_opts(cfg, opts)

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
  packer.init {
    plugin_package = cfg.package,
  }
end, { notify = vim.log.levels.INFO })

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
    tag = pack.tag,
    lock = pack.pin,
    ft = pack.ft,
    opt = pack.opt,
    run = pack.run,
  }
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

  packer.startup(function(use)
    for _, pack in ipairs(packs) do
      use(transform(pack))
    end
  end)
end

return M
