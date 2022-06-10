# pack-config.nvim

Mod the package, Unified package installation and configuration in one file, decoupling package manager

## Setup

```lua

require('pack-config').setup {
  loader = require('pack-config.loader.packer'),
  loader_opts = {},
  scanner = require('pack-config.scanner.fd'),
  scanner_opts = {},
  scan_paths = { '/path/subpath/pre', '/path/subpath' },
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
      '[pack_item_url]',
      as = '',
      branch = '',
      tag = '',
      commit = '',
      pin = '',
      ft = {},
      opt = true,
      run = function() end,
      rely = {
        '[other_pack_item_url]'
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

`vim.fn.stdpath('data') .. '/site/pack/init/start'`: predownload pack loader location

`vim.fn.stdpath('data') .. '/site/pack/packer/start'`: pack loader download location

## TODO

- [ ] lua check and style
- [x] pack loader add init function
- [x] deprecate tip
- [x] context muti instance
- [x] external lua file support
- [x] topologic sort
  - [x] circle check
- [x] pack_name repeat error
- [x] refact log file (level with endpoin)
- [x] log use vim.notify
- [x] setfenv with setup and config
