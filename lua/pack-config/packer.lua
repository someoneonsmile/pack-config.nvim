local util = require('pack-config.util')
local log = require('pack-config.log')
local Context = require('pack-config.context')
local Const = require('pack-config.const')
local Profile = require('pack-config.profile')

local convert = util.convert
local fn = util.fn
local pd = util.predicate
local tbl = util.tbl

local loader
local env

local M = {}

local regist_packs = Context:new(Const.pack_context_key)
local relys = {}
local resources = {}
local deprecateds = {}

-- 解析依赖
local function parse_rely(pack_resources)
  pack_resources = convert.to_table_n(pack_resources, 2)
  local results = {}
  if pd.is_empty(pack_resources) then
    return results
  end
  for _, pack_resource in pairs(pack_resources) do
    local rely = convert.to_table_n(pack_resource.rely, 2)
    if pd.not_empty(rely) then
      tbl.list_extend(results, parse_rely(rely))
      -- remove the rely's rely
      vim.tbl_map(function(it)
        it.rely = nil
        return it
      end, rely)
      tbl.list_extend(results, rely)
    end
  end
  return results
end

-- 启动设置
M.setup = function(opts)
  loader = opts.loader
  assert(loader ~= nil, 'please config the loader')
  env = opts.env or {}
end

-- 注册插件
M.regist = function(packs)
  local with_env = fn.with_env(env)
  for _, pack in pairs(packs) do
    local pack_resources = pack.resources
    tbl.list_extend(relys, parse_rely(pack_resources))
    tbl.list_extend(resources, pack_resources)
    deprecateds = tbl.tbl_force_extend(deprecateds, tbl.list_to_map(pack_resources.deprecated, fn.first, fn.orign))
    pack.setup = fn.once(with_env(pack.setup))
    pack.config = fn.once(with_env(pack.config))

    if regist_packs:get(pack.name) ~= nil then
      error(pack.name .. ' already exists', vim.log.levels.ERROR)
    end
    regist_packs:set(pack.name, pack)
  end
  relys = tbl.list_distinct(fn.first, relys)
  resources = tbl.list_distinct(fn.first, resources)
end

-- 获取 pack
M.get_pack = function(pack_name)
  return regist_packs:get(pack_name)
end

-- 提示过期插件及替换插件
local deprecated_tip = function(items)
  local tips = {}
  for _, v in pairs(items) do
    local path = fn.first(v)
    local deprecated_config = deprecateds[path]
    if deprecated_config then
      table.insert(
        tips,
        string.format('%s is deprecated, replace with %s', deprecated_config[1], deprecated_config.replace_with)
      )
    end
  end

  if #tips > 0 then
    log.warn(table.concat(tips, '\n'))
  end
end

-- 插件管理器注册插件
M.done = function()
  local all_resources = tbl.list_distinct(fn.first, tbl.list_extend({}, relys, resources))
  deprecated_tip(all_resources)

  log.debug('pack loader will load :', all_resources)
  loader.load(all_resources)
  if regist_packs:is_empty() then
    return
  end

  -- topo_sort
  local sorter = util.topo_sort:new(function(_, v)
    return v.name
  end, function(v)
    return fn.with_default {}(v.after)
  end)
  local regist_packs_sorted = sorter:sort(regist_packs)

  -- call setup() and config()
  for _, pack in ipairs(regist_packs_sorted) do
    Profile.start('setup-config', pack.name .. '::setup')
    local ok, msg = pcall(pack.setup)
    Profile.stop('setup-config', pack.name .. '::setup')
    if not ok then
      log.error(pack.name .. '::setup', msg)
    end
  end
  for _, pack in ipairs(regist_packs_sorted) do
    Profile.start('setup-config', pack.name .. '::config')
    local ok, msg = pcall(pack.config)
    Profile.stop('setup-config', pack.name .. '::config')
    if not ok then
      log.error(pack.name .. '::config', msg)
    end
  end
end

return M
