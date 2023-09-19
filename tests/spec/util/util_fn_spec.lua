local fn = require('pack-config.util.fn')

describe('util fn test', function()
  it('fn with_default', function()
    local a, b = fn.with_default {}(nil, { 'b' })
    assert.are.same({}, a)
    assert.are.same({ 'b' }, b)
  end)
end)
