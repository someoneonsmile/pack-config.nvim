local log = require('pack-config.log')
local util = require('pack-config.util')
local fn = util.fn
local tbl = util.tbl
local Set = util.set

local with_log_error_handler = fn.with_error_handler(function(msg)
  log.error('vim_pack error ' .. msg)
end)

local gh = function(x)
  return 'https://github.com/' .. x
end

local default_cfg = {
  url_format = gh,
}
local cfg = default_cfg

-- ----------------------------------------------------------------------
--    - M -
-- ----------------------------------------------------------------------

local M = {}

M.name = 'vim.pack'

M.exist = function()
  return vim.pack ~= nil
end

M.init = fn.once(function(opts)
  -- error('vim.pack only support 0.12~')
  cfg = tbl.tbl_keep_deep_extend(opts, default_cfg)
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
  local src, run = pack[1], pack.run
  local name = src:match('.+/(.+)')
  local pack_run
  local pack_build
  if type(run) == 'string' then
    if run:sub(1, 1) == ':' then
      pack_run = function()
        vim.cmd(run)
      end
    else
      pack_build = function()
        vim.system({ 'bash', '-c', run }, { cwd = vim.fn.stdpath('data') .. '/site/pack/core/opt/' .. name })
      end
    end
  elseif type(run) == 'function' then
    pack_run = run
  end
  return {
    src = cfg.url_format(src),
    name = pack.as,
    version = pack.branch or pack.commit or pack.tag,
    data = { run = pack_run, build = pack_build },
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
    -- 'pin',
    -- 'opt',
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
M.load = function(packs)
  packs = packs or {}
  not_support_opts_tip(packs)

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name, kind = ev.data.spec.name, ev.data.kind
      log.info('enter PackChanged ' .. name)
      local pack_data = ev.data.spec.data or {}
      local run = pack_data.run
      local build = pack_data.build
      if type(run) ~= 'function' and type(build) ~= 'function' then
        return
      end
      -- kind: install update delete
      if kind ~= 'delete' then
        if build then
          with_log_error_handler(build)()
        end
        if run then
          if not env.data.active then
            vim.cmd.packadd(name)
          end
          with_log_error_handler(run)()
        end
      end
    end,
  })
  vim.pack.add(vim.tbl_map(transform, packs))
end

return M
