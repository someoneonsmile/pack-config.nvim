local enhance = require('pack-config.util.enhance')

describe('enhance test', function()
  it('load env', function()
    local content = 'print("foo:",foo) return function () if foo == "bar" then return 1 else return 0 end end'
    local env = setmetatable({ foo = 'bar' }, { __index = _G })
    local func, err = assert(load(content, 'abc', 'bt', env))
    if err ~= nil then
      print(err)
    end
    assert.same(1, func()())
  end)
  it('dofile env', function()
    local env = { foo = 'bar' }
    local content = 'print("foo:",foo) return function () if foo == "bar" then print(foo) end return foo end'
    local tmpname = os.tmpname()
    local file = assert(io.open(tmpname, 'w+'))
    file:write(content)
    file:close()
    local func = assert(enhance.dofile(tmpname, 'bt', env))
    assert.same('bar', func())
  end)
end)
