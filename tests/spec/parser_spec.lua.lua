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

  it('test', function() end)
end)
