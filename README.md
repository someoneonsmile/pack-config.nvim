# pack-config.nvim

Modular package, package's installation and configuration in same file, decoupling package manager

## Setup

```lua

require('pack-config').setup {
  -- must
  scan_paths = { '/path/pre', '/path/subpath', '/path/after' },

  -- optional
  -- default to select from the order list [packer.nvim, paq-nvim, lazy.nvim] if exists
  loader = require('pack-config.loader.packer'),
  -- optional
  loader_opts = {},
  -- optional
  -- default to select from the order list [uv, fd] if exists
  -- uv: which use vim.loop.fs_scandir
  -- fd: which use the cli fd
  scanner = require('pack-config.scanner.uv'),
  -- optional
  -- default for uv: https://github.com/someoneonsmile/pack-config.nvim/blob/main/lua/pack-config/scanner/uv.lua#L3C1-L8C2
  scanner_opts = {},
  -- optional, default
  parser = require('pack-config.parser.lua'),
  -- optional
  parser_opts = {},

  -- optional, env for all pack file
  env = {
    -- default, for get other pack
    pack = function(pack_name)
      ...
    end
  },

  -- optional, provide convenience for debug, bisect
  block_list = {
    '[pack_name_a]',
    '[pack_name_b]',
    -- '[pack_name_c]',
  },
}
```

## Default Pack File Format

<details open>

<summary> detail </summary>

```lua
-- pack config
local M = {}

-- must
M.name = '[pack_name]'

-- optional
-- subs will eventually be merged into the main pack,
-- similar to the conf.d directory.
-- subs support multi-level nesting.
M.subs = {
  require('somepath'),
  {
    resources = {
      -- resource
      {
        '[resource_url]',
        as = '',
        branch = '',
        tag = '',
        commit = '',
        -- lock, skip updating this plugin
        pin = false,
        -- manually marks a plugin as optional
        opt = true,
        -- update / install hook
        run = function() end,
        rely = {
          -- nested resource
          {'[other_resource_url]', rely = {}}
        },
      }
    }
    setup = function() end,
    config = function() end,
    -- lazy = true
    -- lazy also support function that return boolean
    lazy = function()
      return true
    end
    -- subs = ...
  },
}

-- optional
-- format: string, table or function
M.resources = function()
  return {
    -- resource
    {
      '[resource_url]',
      as = '',
      branch = '',
      tag = '',
      commit = '',
      -- lock, skip updating this plugin
      pin = false,
      -- manually marks a plugin as optional
      opt = true,
      -- update / install hook
      run = function() end,
      rely = {
        -- nested resource
        {'[other_resource_url]', rely = {}}
      },
    },
    -- optional, placing deprecated resources
    -- when 'deprecated_resource' use by other pack, will log the deprecated and replace_with tip
    deprecated = {
      { '[deprecated_resource]', replace_with = '[new_resource]'}
    }
  }
end

-- optional
-- format: string, table or function
M.after = { '[other_pack_name]' }

-- optional
-- pack setup
M.setup = function()
  -- use pack the env fn to load other pack
  local other_pack = pack('other_pack_name')
  ...
end

-- optional
-- config run after all pack's setup
M.config = function()
  -- use pack fn to load other pack
  local other_pack = pack('other_pack_name')
  ...
end

-- lazy = true
-- lazy also support function that return boolean
lazy = function()
  return true
end

return M
```

### `resources` variants

<details>

<summary> variants </summary>

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
      -- nested resource
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
      -- nested resource
      {'[other_resource_url]', rely = {}}
    },
  },
  -- optional, placing deprecated resources
  -- when use by other pack, will log the deprecated tip
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

### `after` variants

<details>

<summary> variants </summary>

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

## Download Package Location

`vim.fn.stdpath('data') .. '/site/pack/init/start'`: predownload pack loader location

`vim.fn.stdpath('data') .. '/site/pack/packer/start'`: pack loader download location

## Profile

`:lua require('pack-config.profile').report()`

## Custom scanner, parser and loader

<details>

<summary> detail </summary>

### Scanner

to get the pack file

<details>

<summary> Format </summary>

```lua
local M = {}

M.exist = bool or function return bool

-- optional
M.init = function(opts) end

-- scan the paths return the pack_files
M.scan = function(paths)

end
```

</details>

### Parser

to parse the pack file

<details>

<summary> Format </summary>

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

</details>

### Loader

use package manager to load the pack

<details>

<summary> Format </summary>

```lua
local M = {}

M.exist = bool or function return bool

-- optional
M.init = function(opts) end

-- parse the pack file to the format
M.load = function(packs)

end
```

</details>

</details>

## TODO

- [x] lua check and style
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
- [x] profile
- [x] error handler
- [ ] parallel
