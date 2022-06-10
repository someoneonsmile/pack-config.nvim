# pack-config.nvim

模块化包，统一包的安装与配置在一个文件，解耦包管理器

## Setup

```lua

require('pack-config').setup {
  loader = require('pack-config.loader.packer'),
  loader_opts = {},
  scanner = require('pack-config.scanner.fd'),
  scanner_opts = {},
  scan_paths = { 'lua/somepath/pre', 'lua/somepath' },
}
```

## Pack File Format

```lua
-- pack config
local M = {}

M.name = '[pack_name]'

M.is_pack = true

M.resources = function()
  return {
    {
      '[resource_url]',
      as = '',
      branch = '',
      tag = '',
      commit = '',
      pin = '',
      ft = {},
      opt = true,
      run = function() end,
      rely = {
        '[other_resource_url]'
      },
    },
  }
end

M.after = function()
  return {
    '[other_pack_name]'
  }
end

-- pack setup config
M.setup = function()

end

-- pack config after all pack setup
M.config = function()

end

return M
```

## Download Package Location

`vim.fn.stdpath('data') .. '/site/pack/init/start'`: 预下载包路径，包括包管理器，启动依赖等

`vim.fn.stdpath('data') .. '/site/pack/packer/start'`: 特定包管理器路径
