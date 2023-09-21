local util = require('pack-config.util')

describe('util test', function()
  -- ----------------------------------------------------------------------
  --    - util.id -
  -- ----------------------------------------------------------------------

  it('auto gen id', function()
    local auto_id = util.id:new('test')
    assert.same(1, auto_id:inc())
    assert.same(2, auto_id:inc())
  end)

  -- ----------------------------------------------------------------------
  --    - util.predicate -
  -- ----------------------------------------------------------------------

  it('predicate is_type', function()
    local v = { 'v' }
    assert.is_true(util.predicate.is_type('table', v))
    assert.is_true(util.predicate.is_type({ 'table' }, v))
    assert.is_true(util.predicate.is_type({ 'table', 'string' }, v))
    assert.is_true(util.predicate.is_type('list', v))
    assert.is_true(util.predicate.is_type({ 'list', 'string' }, v))
    assert.has_error(function()
      util.predicate.is_type(nil, v)
    end)
  end)

  -- ----------------------------------------------------------------------
  --    - util.convert -
  -- ----------------------------------------------------------------------

  it('to_table_n', function()
    local t = function()
      return {
        { 'a' },
        { 'b' },
        'c',
      }
    end
    assert.same({ { 'a' }, { 'b' }, { 'c' } }, util.convert.to_table_n(t, 2))
  end)
end)
