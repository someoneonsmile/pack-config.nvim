local util = require('pack-config.util')
local enhance = require('pack-config.util.enhance')
local eq = assert.same
local neq = assert.are_not.same

describe('enhance test', function()
  it('load env', function()
    local run = function(r)
      return r()
    end
    local content = 'print("foo:",foo) return function () if foo == "bar" then return 1 else return 0 end end'
    local env = setmetatable({ foo = 'bar' }, { __index = _G })
    local func, err = assert(load(content, 'abc', 'bt', env))
    if err ~= nil then
      print(err)
    end
    eq(1, run(func()))
  end)
  it('dofile env', function()
    local run = function(r)
      return r()
    end
    local env = { foo = 'bar' }
    local content = 'print("foo:",foo) return function () if foo == "bar" then print(foo) end return foo end'
    local tmpname = os.tmpname()
    local file = assert(io.open(tmpname, 'w+'))
    file:write(content)
    file:close()
    local ok, func = enhance.dofile(tmpname, 'bt', env)
    eq('bar', run(func))
  end)
end)
