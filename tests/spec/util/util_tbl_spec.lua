local tbl = require('pack-config.tbl')

describe('util tbl test', function()
  it('tbl tbl_keep_extend', function()
    local tbl_keep_extend = tbl.tbl_keep_extend
    assert.same({ 1 }, tbl_keep_extend(nil, { 1 }, { '1' }))
    assert.same({ 1, { 1, 2 } }, tbl_keep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
  end)

  it('tbl tbl_keep_deep_extend', function()
    local tbl_keep_deep_extend = tbl.tbl_keep_deep_extend
    assert.same({ 1 }, tbl_keep_deep_extend(nil, { 1 }, { '1' }))
    assert.same({ 1, { 1, 2 } }, tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    assert.same(
      vim.tbl_deep_extend('keep', { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }),
      tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } })
    )
    assert.are_not.same({ 1, { 1, 2, '3' } }, tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }))
  end)

  it('tbl tbl_force_extend', function()
    local tbl_force_extend = tbl.tbl_force_extend
    assert.same({ '1' }, tbl_force_extend(nil, { 1 }, { '1' }))
    assert.same({ '1', { '1', '2' } }, tbl_force_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    assert.same({ a = { 'b' } }, tbl_force_extend(nil, { a = { 'a' } }, { a = { 'b' } }))
    assert.same({ a = { 'a' }, b = { 'b' } }, tbl_force_extend(nil, { a = { 'a' } }, { b = { 'b' } }))
  end)

  it('tbl tbl_force_deep_extend', function()
    local tbl_force_deep_extend = tbl.tbl_force_deep_extend
    assert.same({ '1' }, tbl_force_deep_extend(nil, { 1 }, { '1' }))
    assert.same({ '1', { '1', '2' } }, tbl_force_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    assert.same(
      vim.tbl_deep_extend('force', { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }),
      tbl_force_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } })
    )
    assert.same({ '1', { '1', '2', '3' } }, tbl_force_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }))
    assert.are_not.same({ '1', { '1', '2', 3 } }, tbl_force_deep_extend(nil, { 1, { 1, 2, 3 } }, { '1', { '1', '2' } }))
  end)
end)
