# pack-config.nvim

Modular package, Unified package installation and configuration in same file, decoupling package manager

## Setup

```lua

require('pack-config').setup {
  -- optional
  -- default to select from the order list [packer.nvim, paq-nvim] if exists
  loader = require('pack-config.loader.packer'),
  -- optional
  loader_opts = {},
  -- optional
  -- default to select from the order list [vim.loop.fs_scandir, fd] if exists
  scanner = require('pack-config.scanner.fd'),
  -- optional
  scanner_opts = {},
  -- optional, default
  parser = require('pack-config.parser.lua'),
  -- optional
  parser_opts = {},

  -- must
  scan_paths = { '/path/subpath/pre', '/path/subpath' },

  -- optional, env for setup and config fn
  env = {
    -- for get other pack
    pack = function(name)
      ...
    end
  },

  -- optional, provide convenience for debug, bisect
  block_list = {
      '[pack_name]'
    },
}
```

## Default pack File Format

```lua
-- pack config
local M = {}

-- must
M.name = '[pack_name]'

-- must
M.is_pack = true

-- optional
-- string, table or function
M.resources = function()
  return {
    -- resource
    {
      '[resource_url]',
      as = '',
      branch = '',
      tag = '',
      commit = '',
      pin = '',
      opt = true,
      run = function() end,
      rely = {
        -- nested resource
        {'[other_resource_url]', rely = {}}
      },
    },
  }
end

-- optional
-- string, table or function
M.after = { '[other_pack_name]' }

-- pack setup config
M.setup = function()
  -- use pack fn to load other pack
  local other_pack = pack('other_pack_name')
  ...
end

-- pack config after all pack setup
M.config = function()
  -- use pack fn to load other pack
  local other_pack = pack('other_pack_name')
  ...
end

return M
```

## Download Package Location

`vim.fn.stdpath('data') .. '/site/pack/init/start'`: predownload pack loader location

`vim.fn.stdpath('data') .. '/site/pack/packer/start'`: pack loader download location

## Custom scanner, parser and loader

### Scanner

to get the pack file

#### Format

```lua
local M = {}

M.exist = bool or function return bool

-- optional
M.init = function(opts) end

-- scan the paths return the pack_files
M.scan = function(paths)

end
```

### Parser

to parse the pack file

#### Format

```lua
local M = {}

M.exist = bool or function return bool

-- optional
M.init = function(opts) end

M.is_pack = function(pack) return true end

-- parse the pack file to the format
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

### Loader

use package manager to load the pack

#### Format

```lua
local M = {}

M.exist = bool or function return bool

-- optional
M.init = function(opts) end

-- parse the pack file to the format
M.load = function(packs)

end
```

## TODO

- [ ] lua check and style
- [x] pack loader add init function
- [x] deprecate tip
- [x] context muti instance
- [x] external lua file support
- [x] topologic sort
  - [x] circle check
- [x] pack name repeat error
- [x] refact log file (level with endpoin)
- [x] log use vim.notify
- [x] setfenv with setup and config
- [x] split parser
- [ ] profile
- [ ] parallel
