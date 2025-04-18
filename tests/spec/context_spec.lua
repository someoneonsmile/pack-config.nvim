local Context = require('pack-config.context')

describe('context test', function()
  -- ----------------------------------------------------------------------
  --    - util.id -
  -- ----------------------------------------------------------------------

  it('context pair', function()
    local a = Context:new('a')
    local i = 0
    local paired_private = false
    for key, _ in pairs(a) do
      i = i + 1
      if key ~= nil and string.match(key, '^_') then
        paired_private = true
      end
    end
    assert.same(0, i)
    assert.same(false, paired_private)
  end)
end)
