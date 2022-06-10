local util = require('pack-config.util')
local fn = require('pack-config.util.fn')
local log = require('pack-config.log')
local Context = require('pack-config.context')
local Const = require('pack-config.const')

local loader

local env

local M = {}

local regist_packs = Context:new(Const.pack_context_key)
local relys = {}
local resources = {}
local deprecateds = {}

-- 解析依赖
local function parse_rely(pack_resources)
  local results = {}
  if util.tbl_isempty(pack_resources) then
    return results
  end
  for _, pack_resource in pairs(pack_resources) do
    if util.tbl_notempty(pack_resource.rely) then
      vim.list_extend(
        results,
        parse_rely(vim.tbl_flatten(vim.tbl_map(
          function(it)
            return it.rely
          end,
          vim.tbl_filter(function(it)
            return util.tbl_notempty(it.rely)
          end, pack_resource.rely)
        )))
      )
      vim.list_extend(
        results,
        vim.tbl_map(function(it)
          return util.string_or_table(it)
        end, pack_resource.rely)
      )
    end
  end
  return results
end

M.is_pack = function(pack)
  return pack['is_pack']
    and type(pack['name']) == 'string'
    and type(pack['resources']) == 'function'
    and type(pack['setup']) == 'function'
    and type(pack['config']) == 'function'
end

-- 启动设置
M.setup = function(opts)
  loader = opts.loader
  assert(loader ~= nil, 'please config the loader')
  env = opts.env or {}
end

-- 注册插件
M.regist = function(packs)
  for _, pack in pairs(packs) do
    if M.is_pack(pack) then
      local pack_resources = pack.resources()
      util.list_extend(relys, parse_rely(pack_resources))
      util.list_extend(resources, pack_resources)
      util.tbl_force_extend(deprecateds, util.list_to_map(pack_resources.deprecated, fn.first, fn.orign))
      pack.setup = fn.once(fn.with_env(env)(pack.setup))
      pack.config = fn.once(fn.with_env(env)(pack.config))

      if regist_packs:get(pack.name) ~= nil then
        error(pack.name .. ' already exists', vim.log.levels.ERROR)
      end
      regist_packs:set(pack.name, pack)
    end
  end
  relys = util.list_distinct(fn.first, relys)
  resources = util.list_distinct(fn.first, resources)
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
      util.list_extend(
        tips,
        string.fmt('%s is deprecated, replace with %s', deprecated_config[1], deprecated_config.replace_with)
      )
    end
  end

  if #tips > 0 then
    log.warn(table.concat(tips, '\n'))
  end
end

-- 插件管理器注册插件
M.done = function()
  local all_resources = util.list_distinct(fn.first, util.list_extend({}, relys, resources))
  deprecated_tip(all_resources)
  log.debug('pack loader will load :', vim.inspect(all_resources))
  loader.load(all_resources)
  if regist_packs:is_empty() then
    return
  end

  -- topo_sort
  local sorter = util.topo_sort:new(function(_, v)
    return v.name
  end, function(v)
    return util.fn.with_default {}(util.string_or_table(v.after))
  end)
  local regist_packs_sorted = sorter:sort(regist_packs)

  -- call setup() and config()
  for _, pack in ipairs(regist_packs_sorted) do
    local ok, msg = pcall(pack.setup)
    if not ok then
      log.error(msg)
    end
  end
  for _, pack in ipairs(regist_packs_sorted) do
    local ok, msg = pcall(pack.config)
    if not ok then
      log.error(msg)
    end
  end
end

return M
