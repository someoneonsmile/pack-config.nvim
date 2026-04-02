# AGENTS.md - pack-config.nvim

## Project Overview

**pack-config.nvim** is a Neovim plugin that provides modular package management—keeping a package's installation and configuration in the same file while decoupling the package manager.

- **Language**: Lua (targeting LuaJIT/Neovim)
- **Type**: Neovim plugin
- **Test Framework**: plenary.nvim (busted)
- **Linters**: luacheck, selene
- **Formatter**: stylua

---

## Build/Lint/Test Commands

### Run All Tests

```bash
make test
```

Or directly:

```bash
nvim --headless -c "PlenaryBustedDirectory tests/spec/ {minimal_init = 'tests/minimal_init.vim'}"
```

### Run a Single Test File

```bash
nvim --headless -c "PlenaryBustedFile tests/spec/util/util_topo_sort_spec.lua" tests/minimal_init.vim
```

### Run Tests Matching a Pattern

```bash
nvim --headless -c "PlenaryBustedDirectory tests/spec/ {minimal_init = 'tests/minimal_init.vim', --pattern='topo'}"
```

### Lint with Luacheck

```bash
luacheck .
```

### Format with StyLua

```bash
stylua .
```

### Type Check with Selene

```bash
selene .
```

---

## Code Style Guidelines

### Formatting

| Rule        | Value                   |
|-------------|-------------------------|
| Column width | 120 characters         |
| Indent      | 2 spaces (no tabs)     |
| Line endings | Unix (LF)              |
| Quote style | AutoPreferSingle        |
| Call parentheses | NoSingleTable     |

Run formatter before committing:

```bash
stylua .
```

### Naming Conventions

| Element           | Convention   | Example                          |
|-------------------|--------------|----------------------------------|
| Modules           | snake_case   | `lua/pack-config/util/fn.lua`    |
| Functions         | snake_case   | `tbl_isempty`, `with_default`    |
| Variables         | snake_case   | `local pack_paths = ...`         |
| Table keys        | snake_case   | `{ pack_name = 'foo' }`          |
| Constants         | UPPER_SNAKE  | `local M = {}` for module, see below |
| Private variables | prefix `_`   | `_private_fn`, `_internal_state` |
| Class-like tables | PascalCase   | `local Log = {}` (constructor)  |
| Method receivers  | `self`        | `function M:new(name, o)`        |

### Module Structure Pattern

```lua
local util = require('pack-config.util')
local log = require('pack-config.log')

-- Constants and local helpers first
local M = {}

-- ----------------------------------------------------------------------
--    - section name -
-- ----------------------------------------------------------------------

function M.public_function(arg)
  return 'result'
end

local function private_function(arg)
  return 'internal'
end

return M
```

### Comment Style

Use section separators for major divisions:

```lua
-- ----------------------------------------------------------------------
--    - section name -
-- ----------------------------------------------------------------------
```

Single-line comments use `--` prefix:

```lua
-- This is a comment
local x = 10  -- inline comment
```

Docstring-style comments for functions:

```lua
-- @param opts table configuration options
-- @return boolean success
function M.setup(opts)
  ...
end
```

### Imports

- Use `local` for all requires
- Group requires by type (util, external, standard)
- Use lazy loading via `util.lazy_require` for optional submodules

```lua
local packer = require('pack-config.packer')
local util = require('pack-config.util')
local log = require('pack-config.log')
local Profile = require('pack-config.profile')

-- For optional/lazy loading:
local M = setmetatable({}, {
  __index = function(self, k)
    local v = require('pack-config.util.' .. k)
    self[k] = v
    return v
  end,
})
```

### Error Handling

- Use `pcall` for protected calls when loading external code
- Use `vim.notify` via the log module for user-facing errors
- Throw errors with `error()` for programmer errors (invalid state)
- Log warnings with `log.warn()` for recoverable issues

```lua
-- Loading external code
local ok, pack = pcall(require, some_path)
if not ok then
  log.error('load lua file failed, path = ' .. pack_path, pack)
end

-- Programmer errors
if invalid_state then
  error('context_name: ' .. name .. ' has exist')
end
```

### Type Handling

Lua is dynamically typed. Follow these conventions:

- Use `vim.tbl_isempty()`, `vim.tbl_deep_extend()` from Neovim stdlib
- Use `type(x) == 'table'` for explicit type checks
- Use predicate functions: `pd.is_nil()`, `pd.is_function()`, etc.
- Handle `nil` gracefully—never assume table keys exist

```lua
-- Safe table access
if pd.tbl_isempty(tbl) then
  return default_value
end

-- Deep extend for config merging
cfg = vim.tbl_deep_extend('force', default_cfg, opts)
```

### Test Patterns (plenary.nvim/busted)

```lua
local some_module = require('pack-config.some_module')

describe('module name test', function()
  -- before_each and after_each hooks
  before_each(function()
    -- setup
  end)

  after_each(function()
    -- teardown
  end)

  it('should do something specific', function()
    local result = some_module.do_something()
    assert.same({ expected = 'value' }, result)
  end)

  it('should handle error cases', function()
    assert.has_error(function()
      some_module.raise_error()
    end)
  end)
end)
```

**Available assertions**: `assert.same()`, `assert.equals()`, `assert.truthy()`, `assert.falsy()`, `assert.has_error()`, `assert.spy()`, `assert.stub()`

### Logging

Use the project's log module:

```lua
local log = require('pack-config.log')

log.trace('detailed debug info')
log.debug('debug message')
log.info('information')
log.warn('warning message')
log.error('error message')
log.fatal('fatal error')

-- Formatted variants
log.fmt_info('Value is %s', some_value)

-- Lazy evaluation (expensive strings)
log.lazy_debug(function() return expensive_string_computation() end)
```

### Metatable Patterns

**OOP-style constructor**:

```lua
local M = {}

function M:new(name, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
```

**Lazy loading submodule**:

```lua
local M = {}

setmetatable(M, {
  __index = function(self, k)
    local v = require('pack-config.util.' .. k)
    self[k] = v
    return v
  end,
})

return M
```

### File Organization

```
lua/pack-config/
├── init.lua          -- Main entry point
├── loader.lua         -- Package loader abstraction
├── parser.lua        -- Pack file parser
├── scanner.lua       -- File scanner
├── log.lua           -- Logging utility
├── profile.lua       -- Performance profiling
├── context.lua       -- Context management
├── const.lua         -- Constants
├── helper.lua        -- Helper utilities
├── packer.lua        -- Packer integration
├── util/             -- Utility modules
│   ├── fn.lua        -- Function utilities
│   ├── tbl.lua        -- Table utilities
│   ├── set.lua        -- Set operations
│   └── ...
└── loader/            -- Loaders (packer, lazy, paq)
    ├── packer.lua
    ├── lazy.lua
    └── paq.lua
```

---

## Configuration Files

| File           | Purpose                              |
|----------------|--------------------------------------|
| `stylua.toml`  | Code formatting rules                |
| `selene.toml`  | Static analysis (vim stdlib types)  |
| `.luacheckrc`  | Luacheck configuration               |
| `.editorconfig`| Editor defaults                      |
| `vim.toml`     | Selene vim type definitions          |
| `makefile`     | Test command                         |

---

## Git Workflow

- Run tests before committing: `make test`
- Run formatter before committing: `stylua .`
- Lint check: `luacheck . && selene .`

---

## Common Tasks

### Adding a New Utility Module

1. Create `lua/pack-config/util/your_module.lua`
2. Follow module structure pattern
3. Add lazy require in `util.lua` or explicit require where needed
4. Add tests in `tests/spec/util/your_module_spec.lua`

### Adding a New Loader/Scanner/Parser

1. Create in appropriate directory (`loader/`, `scanner/`, `parser/`)
2. Implement required interface (see README for format)
3. Register in main module if needed

### Debugging

Enable file logging via `vim.notify` with level `warn` or higher. Log files are written to `vim.fn.stdpath('cache') .. '/pack-config.log'`.

Profile timing data with `require('pack-config.profile').report()`.
