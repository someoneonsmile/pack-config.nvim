# pack-config.nvim

Mod the package, Unified package installation and configuration in one file, decoupling package manager

## Setup

```lua

require('pack-config').setup {
  loader = require('pack-config.loader.packer'),
  loader_opts = {},
  scanner = require('pack-config'.scanner.fd'),
  scanner_opts = {},
  scan_paths = { 'lua/somepath/pre', 'lua/somepath' },
}
```

## Pack File Format

```lua
local M = {}

M.name = 'name'

M.is_pack = true

M.resources = function()
  return {
    {
      '[pack url]',
      as = '',
      branch = '',
      tag = '',
      commit = '',
      pin = '',
      ft = {},
      opt = true,
      run = function() end,
      rely = {},
    },
  }
end


M.after = function()
  return {
    '[other config pack]'
  }
end


# pack setup config
M.setup = function()

end


# pack config after all pack setup
M.config = function()

end

return M
```

## Download Package Location

`vim.fn.stdpath('data') .. '/site/pack/init/start'`: 预下载包路径，包括包管理器，启动依赖等

`vim.fn.stdpath('data') .. '/site/pack/packer/start'`: 特定包管理器路径

## TODO

- [x] 选择包管理器
- [ ] 文档补充文件结构及约定部分
- [ ] lua check and style
- [x] pack loader 添加 init 方法
- [x] 更改 lua 模块结构 去 init.lua builtin
- [x] deprecate tip
- [x] after 拓扑 sort
- [x] context 多实例
- [ ] 外部 lua file support
- [x] topologic sort 拓扑排序
  - [x] 拓扑排序 circle check
  - [ ] 拓扑排序 name 缺失时 自动生成序号
  - [ ] name 重复 error
- [ ] ID 生成器
- [x] refact log file (level with endpoin)
- [x] log use vim.notify
- [x] setfenv with setup and config
