local fn = require('pack-config.util.fn')
local pred = require('pack-config.util.predicate')

describe('util fn test', function()
  it('fn with_default', function()
    local a, b = fn.with_default {}(nil, { 'b' })
    assert.are.same({}, a)
    assert.are.same({ 'b' }, b)
  end)

  it('fn fn_negate', function()
    local not_nil = fn.fn_negate(pred.is_nil)
    assert.are.same(false, not_nil(nil))
    assert.are.same(true, not_nil {})
    assert.are.same(pred.is_nil(nil), not not_nil(nil))
  end)

  it('fn with_default', function()
    local with_default = fn.with_default {}
    assert.same({ {}, { 1 }, { 1, 2 } }, { with_default(nil, { 1 }, { 1, 2 }) })
  end)

  it('fn once', function()
    local a = 0
    local once_fn = fn.once(function()
      a = a + 1
    end)
    once_fn()
    once_fn()
    assert.same(1, a)
  end)

  it('fn curry', function()
    local curry = fn.curry
    local f = curry(function(a, b, c)
      return a + b + c
    end)
    assert.same(f(1)(2)(3)(), 6)
    assert.same(f(1, 2)(3)(), 6)
    assert.same(f(1)(2, 3)(), 6)
    assert.same(f(1, 2, 3)(), 6)
  end)

  it('fn curry_right', function()
    local curry_right = fn.curry_right
    local f = curry_right(function(a, b, c)
      return a .. b .. c
    end)
    assert.same(f('1')('2')('3')(), '321')
    assert.same(f('1', '2')('3')(), '321')
    assert.same(f('1')('2', '3')(), '321')
    assert.same(f('1', '2', '3')(), '321')
  end)

  it('fn pipe', function()
    local pipe = fn.pipe
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
    local with_error_handler = fn.with_error_handler(function(_)
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
