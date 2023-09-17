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
  --    - util.conver -
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

  -- ----------------------------------------------------------------------
  --    - util.fn -
  -- ----------------------------------------------------------------------

  it('fn with_default', function()
    local with_default = util.fn.with_default {}
    assert.same({ {}, { 1 }, { 1, 2 } }, { with_default(nil, { 1 }, { 1, 2 }) })
  end)

  it('fn once', function()
    local a = 0
    local once_fn = util.fn.once(function()
      a = a + 1
    end)
    once_fn()
    once_fn()
    assert.same(1, a)
  end)

  it('fn curry', function()
    local curry = util.fn.curry
    local f = curry(function(a, b, c)
      return a + b + c
    end)
    assert.same(f(1)(2)(3)(), 6)
    assert.same(f(1, 2)(3)(), 6)
    assert.same(f(1)(2, 3)(), 6)
    assert.same(f(1, 2, 3)(), 6)
  end)

  it('fn pipe', function()
    local pipe = util.fn.pipe
    local f = pipe(function(a)
      return a + 1
    end, function(b)
      return b + 2
    end, function(c)
      return c + 3
    end)
    assert.same(f(0), 6)
  end)

  it('fn with_error_handler', function()
    local with_error_handler = util.fn.with_error_handler(function(_)
      return 'error'
    end)
    assert.same(
      with_error_handler(function()
        not_exist_fn()
      end)(),
      'error'
    )
  end)
end)
