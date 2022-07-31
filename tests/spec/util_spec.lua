describe('util test', function()
  local eq = assert.same
  local neq = assert.are_not.same
  local util = require('pack-config.util')

  -- ----------------------------------------------------------------------
  --    - util.tbl -
  -- ----------------------------------------------------------------------

  it('tbl tbl_keep_extend', function()
    local tbl_keep_extend = util.tbl.tbl_keep_extend
    eq({ 1 }, tbl_keep_extend(nil, { 1 }, { '1' }))
    eq({ 1, { 1, 2 } }, tbl_keep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
  end)

  it('tbl tbl_keep_deep_extend', function()
    local tbl_keep_deep_extend = util.tbl.tbl_keep_deep_extend
    eq({ 1 }, tbl_keep_deep_extend(nil, { 1 }, { '1' }))
    eq({ 1, { 1, 2 } }, tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    eq(
      vim.tbl_deep_extend('keep', { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }),
      tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } })
    )
    neq({ 1, { 1, 2, '3' } }, tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }))
  end)

  it('tbl tbl_force_extend', function()
    local tbl_force_extend = util.tbl.tbl_force_extend
    eq({ '1' }, tbl_force_extend(nil, { 1 }, { '1' }))
    eq({ '1', { '1', '2' } }, tbl_force_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    eq({ a = { 'b' } }, tbl_force_extend(nil, { a = { 'a' } }, { a = { 'b' } }))
    eq({ a = { 'a' }, b = { 'b' } }, tbl_force_extend(nil, { a = { 'a' } }, { b = { 'b' } }))
  end)

  it('tbl tbl_force_deep_extend', function()
    local tbl_force_deep_extend = util.tbl.tbl_force_deep_extend
    eq({ '1' }, tbl_force_deep_extend(nil, { 1 }, { '1' }))
    eq({ '1', { '1', '2' } }, tbl_force_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    eq(
      vim.tbl_deep_extend('force', { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }),
      tbl_force_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } })
    )
    eq({ '1', { '1', '2', '3' } }, tbl_force_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }))
    assert.are_not.same({ '1', { '1', '2', 3 } }, tbl_force_deep_extend(nil, { 1, { 1, 2, 3 } }, { '1', { '1', '2' } }))
  end)

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
    eq({ {}, { 1 }, { 1, 2 } }, { with_default(nil, { 1 }, { 1, 2 }) })
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
end)
