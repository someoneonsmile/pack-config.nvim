describe('fn test', function()
  local eq = assert.same
  local neq = assert.are_not.same
  local util = require('pack-config.util')

  -- test with_default
  it('fn with_default', function()
    local with_default = util.fn.with_default {}
    eq({ {}, { 1 }, { 1, 2 } }, { with_default(nil, { 1 }, { 1, 2 }) })
  end)

  -- test tbl_extend
  it('tbl keep extend', function()
    local tbl_keep_extend = util.tbl.tbl_keep_extend
    eq({ 1 }, tbl_keep_extend(nil, { 1 }, { '1' }))
    eq({ 1, { 1, 2 } }, tbl_keep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
  end)

  -- test tbl_extend
  it('tbl deep keep extend', function()
    local tbl_keep_deep_extend = util.tbl.tbl_keep_deep_extend
    eq({ 1 }, tbl_keep_deep_extend(nil, { 1 }, { '1' }))
    eq({ 1, { 1, 2 } }, tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
    eq(
      vim.tbl_deep_extend('keep', { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }),
      tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } })
    )
    neq({ 1, { 1, 2, '3' } }, tbl_keep_deep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2', '3' } }))
  end)

  -- test tbl_extend
  it('tbl force extend', function()
    local tbl_force_extend = util.tbl.tbl_force_extend
    eq({ '1' }, tbl_force_extend(nil, { 1 }, { '1' }))
    eq({ '1', { '1', '2' } }, tbl_force_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
  end)

  -- test tbl_extend
  it('tbl deep force extend', function()
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
end)
