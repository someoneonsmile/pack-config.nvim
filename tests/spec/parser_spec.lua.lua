local parser
local same
local not_same

describe('parser test', function()
  setup(function()
    _G._TEST = true
    parser = require('pack-config.parser.lua')
    same = assert.are.same
    not_same = assert.are_not.same
  end)

  teardown(function()
    _G.TEST = nil
  end)

  it('is_pack', function()
    local tbl_keep_extend = parser.is_pack
    same({ 1 }, tbl_keep_extend(nil, { 1 }, { '1' }))
    not_same({ 1, { 1, 2 } }, tbl_keep_extend(nil, { 1, { 1, 2 } }, { '1', { '1', '2' } }))
  end)
end)
