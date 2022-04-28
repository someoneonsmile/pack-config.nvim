local fn = require('pack-config.util.fn')

local loader

local M = {}

local relys = {}
local resources = {}
local setups = {}
local configs = {}

-- 解析依赖
local parse_rely = function(pack_resources)
  local results = {}
  for _, pack_resource in pairs(pack_resources) do
    vim.tbl_deep_extend('force', results, parse_rely(vim.tbl_flatten(tbl_map(function(it) return it.rely end, vim.tbl_filter(function(it) return not vim.tbl_isempty(it.rely) end, pack_resource.relay)))))
    vim.tbl_deep_extend('force', results, pack_resource.rely)
  end
end

M.is_pack = function(pack)
  return pack['is_pack'] and pack['resources'] and type(pack['setup']) == "function" and type(pack['config']) == "function"
end


-- 启动设置
M.setup = function(opts)
  loader = opts.loader
end

-- 注册插件
M.regist = function(packs)
  for _, pack in ipairs(packs) do
    if M.is_pack(pack) then
      local pack_resources = pack.resources()
      vim.tbl_extend('force', relys, parse_rely(pack_resources))
      vim.tbl_extend('force', resources, pack_resources)
      pack.setup = fn.once(pack.setup)
      table.insert(setups, pack.setup)
      pack.config = fn.once(pack.config)
      table.insert(configs, pack.configs)
    end
  end
end

-- 插件管理器注册插件
M.done = function()
  loader.load(relys)
  loader.load(resources)
  for _, setup in pairs(setups) do
    setup()
  end
  for _, config in pairs(configs) do
    config()
  end
end

return M
