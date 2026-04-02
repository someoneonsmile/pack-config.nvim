# pack-config.nvim

模块化包，统一包的安装与配置在一个文件，解耦包管理器

## 设置

```lua

require('pack-config').setup {
  -- 必须
  scan_paths = { '/path/pre', '/path/subpath', '/path/after' },

  -- 可选
  -- 默认从列表中选择 [packer.nvim, lazy.nvim, paq-nvim, vim.pack] 如果存在
  loader = require('pack-config.loader.packer'),
  -- 可选
  loader_opts = {},
  -- 可选
  -- 默认从列表中选择 [uv, fd] 如果存在
  -- uv: 使用 vim.uv.fs_scandir
  -- fd: 使用 cli fd
  scanner = require('pack-config.scanner.uv'),
  -- 可选
  -- uv 默认配置: https://github.com/someoneonsmile/pack-config.nvim/blob/main/lua/pack-config/scanner/uv.lua#L3C1-L8C2
  scanner_opts = {},
  -- 可选, 默认
  parser = require('pack-config.parser.lua'),
  -- 可选
  parser_opts = {},

  -- 可选, 所有 pack 文件的环境变量
  env = {
    -- 默认, 用于获取其他 pack
    pack = function(pack_name)
      ...
    end
  },

  -- 可选, 用于调试和 bisect
  block_list = {
    '[pack_name_a]',
    '[pack_name_b]',
    -- '[pack_name_c]',
  },
}
```

## 默认 Pack 文件格式

<details open>

<summary> 详情 </summary>

```lua
-- pack 配置
local M = {}

-- 必须
M.name = '[pack_name]'

-- 可选
-- subs 最终会合并到主 pack,
-- 类似于 conf.d 目录.
-- subs 支持多级嵌套.
M.subs = {
  require('somepath'),
  {
    resources = {
      -- 资源
      {
        '[resource_url]',
        as = '',
        branch = '',
        tag = '',
        commit = '',
        -- lock, 跳过更新此插件
        pin = false,
        -- 手动标记为可选
        opt = true,
        -- 更新/安装钩子
        run = function() end,
        rely = {
          -- 嵌套资源
          {'[other_resource_url]', rely = {}}
        },
      }
    }
    setup = function() end,
    config = function() end,
    -- lazy = true
    -- lazy 也支持返回 boolean 的函数
    lazy = function()
      return true
    end
    -- subs = ...
  },
}

-- 可选
-- 格式: string, table 或 function
M.resources = function()
  return {
    -- 资源
    {
      '[resource_url]',
      as = '',
      branch = '',
      tag = '',
      commit = '',
      -- lock, 跳过更新此插件
      pin = false,
      -- 手动标记为可选
      opt = true,
      -- 更新/安装钩子
      run = function() end,
      rely = {
        -- 嵌套资源
        {'[other_resource_url]', rely = {}}
      },
    },
    -- 可选, 放置弃用的资源
    -- 当 'deprecated_resource' 被其他 pack 使用时, 会记录弃用提示和替换建议
    deprecated = {
      { '[deprecated_resource]', replace_with = '[new_resource]'}
    }
  }
end

-- 可选
-- 格式: string, table 或 function
M.after = { '[other_pack_name]' }

-- 可选
-- pack setup
M.setup = function()
  -- 使用 pack env 函数加载其他 pack
  local other_pack = pack('other_pack_name')
  ...
end

-- 可选
-- config 在所有 pack 的 setup 之后运行
-- 通过 vim.schedule 执行
M.config = function()
  -- 使用 pack 函数加载其他 pack
  local other_pack = pack('other_pack_name')
  ...
end

-- lazy = true
-- lazy 也支持返回 boolean 的函数
lazy = function()
  return true
end

return M
```

### `resources` 变体

<details>

<summary> 变体 </summary>

- string

```lua
M.resources = 'resource_url'
```

- table

```lua
M.resources = { 'resource_url_a',  'resource_url_b'}
```

- full table

```lua
M.resources = {
  {
    '[resource_url_a]',
    as = '',
    branch = '',
    tag = '',
    commit = '',
    pin = false,
    opt = false,
    run = function() end,
    rely = {
      -- 嵌套资源
      {'[other_resource_url]', rely = {}}
    },
  },
  {
    '[resource_url_b]',
    as = '',
    branch = '',
    tag = '',
    commit = '',
    pin = false,
    opt = true,
    run = function() end,
    rely = {
      -- 嵌套资源
      {'[other_resource_url]', rely = {}}
    },
  },
  -- 可选, 放置弃用的资源
  -- 当被其他 pack 使用时会记录弃用提示
  deprecated = {
    { '[deprecated_resource_a]', replace_with = '[new_resource_a]'}
    { '[deprecated_resource_b]', replace_with = '[new_resource_b]'}
  }
}

```

- function

```lua
M.resources = function()
  return 'all_kind_above'
end
```

</details>

### `after` 变体

<details>

<summary> 变体 </summary>

- string

```lua
M.after = 'other_pack_name'
```

- table

```lua
M.after = { 'other_pack_name_a', 'other_pack_name_b' }
```

- function

```lua
M.after = function()
  return 'all_kind_above'
end

```

</details>

</details>

## 下载包位置

`vim.fn.stdpath('data') .. '/site/pack/init/start'`: 预下载 pack 加载器位置

`vim.fn.stdpath('data') .. '/site/pack/packer/start'`: pack 加载器下载位置

## Profile

`:lua require('pack-config.profile').report()`

[命令](#命令)

## 自定义 scanner, parser 和 loader

<details>

<summary> 详情 </summary>

### Scanner

用于获取 pack 文件

<details>

<summary> 格式 </summary>

```lua
local M = {}

M.exist = bool or function return bool

-- 可选
M.init = function(opts) end

-- 扫描路径返回 pack_files
M.scan = function(paths)

end
```

</details>

### Parser

用于解析 pack 文件

<details>

<summary> 格式 </summary>

```lua
local M = {}

M.exist = bool or function return bool

-- 可选
M.init = function(opts) end

M.is_pack = function(pack) return true end

-- 解析 pack 文件为指定格式
M.parse = function(pack)
return {
  name = '',
  resources = string, table or function,
  after = string, table or function,
  setup = function() end
  config = function() end
}
end
```

</details>

### Loader

使用包管理器加载 pack

<details>

<summary> 格式 </summary>

```lua
local M = {}

M.exist = bool or function return bool

-- 可选
M.init = function(opts) end

-- 使用包管理器加载 pack
M.load = function(packs)

end
```

</details>

</details>

## 命令

`PackProfileReport`: 报告 pack profile 数据

<details>

<summary> 示例 </summary>

| index | group        | item              | time  |
| ----- | ------------ | ----------------- | ----- |
| 1     | setup-config | lsp::setup        | 13.42 |
| 2     | setup-config | telescope::setup  | 12.60 |
| 3     | setup-config | theme::config     | 11.64 |
| 4     | setup-config | complete::setup   | 11.23 |
| 5     | setup-config | statusline::setup | 10.15 |

</details>

## TODO

- [x] lua check and style
- [x] pack loader 添加 init 函数
- [x] deprecate 提示
- [x] context 多实例
- [x] 外部 lua 文件支持
- [x] 拓扑排序
  - [x] 循环检测
- [x] pack 名称重复错误
- [x] 重构日志文件 (level with endpoint)
- [x] 日志使用 vim.notify
- [x] setfenv 与 setup 和 config
- [x] 拆分 parser
- [x] profile
- [x] 错误处理
- [ ] 并行
- [ ] self update