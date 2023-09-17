local Set = require('pack-config.util.set')

describe('util set test', function()
  it('set from_map', function()
    local set_from_map = Set.from_map { k1 = 'v1', k2 = 'v2' }
    assert.is_true(set_from_map:contains('k1'))
  end)

  it('set from_list', function()
    local set_from_map = Set.from_list { 'k1', 'k2' }
    assert.is_true(set_from_map:contains('k1'))
  end)

  it('set index', function()
    local set_from_list = Set.from_list { 1, 'k1', 'k2' }
    assert.is_true(set_from_list:contains(1))
  end)
end)
