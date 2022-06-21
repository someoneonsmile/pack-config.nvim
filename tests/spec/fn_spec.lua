local eq = assert.are.same
local neq = assert.are_not.same

describe('fn test', function()
  local fn = require('pack-config.util.fn')
  local args = require('pack-config.util.args')

  -- test with_default
  it('test with_default', function()
    local with_default = fn.with_default {}
    eq({ {}, { 1 }, { 1, 2 } }, { with_default(nil, { 1 }, { 1, 2 }) })
  end)
end)
