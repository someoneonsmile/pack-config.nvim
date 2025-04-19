local util = require('pack-config.util')
local topo_sort = util.topo_sort
local fn = util.fn

describe('util topo_sort test', function()
  it('util topo_sort no dependency, keep order', function()
    local sorter = topo_sort:new(function(_, v)
      return v[1]
    end, function(v)
      return fn.with_default {}(v.after)
    end)
    assert.same({ { '1' }, { '2' } }, sorter:sort { { '1' }, { '2' } })
    assert.same({ { '1' }, { '2' }, { '3' } }, sorter:sort { { '1' }, { '2' }, { '3' } })
  end)
  it('util topo_sort simple dependency', function()
    local sorter = topo_sort:new(function(_, v)
      return v[1]
    end, function(v)
      return fn.with_default {}(v.after)
    end)
    assert.same(
      { { '1' }, { '3' }, { '2', after = { '3' } } },
      sorter:sort { { '1' }, { '2', after = { '3' } }, { '3' } }
    )
  end)
  it('util topo_sort dependency before, keep order', function()
    local sorter = topo_sort:new(function(_, v)
      return v[1]
    end, function(v)
      return fn.with_default {}(v.after)
    end)
    assert.same(
      { { '1' }, { '2' }, { '3', after = { '2' } }, { '4' }, { '5' } },
      sorter:sort { { '1' }, { '2' }, { '3', after = { '2' } }, { '4' }, { '5' } }
    )
  end)
  it('util topo_sort simple dependency, but more items', function()
    local sorter = topo_sort:new(function(_, v)
      return v[1]
    end, function(v)
      return fn.with_default {}(v.after)
    end)
    assert.same(
      { { '1' }, { '3' }, { '2', after = { '3' } }, { '4' }, { '5' } },
      sorter:sort { { '1' }, { '2', after = { '3' } }, { '3' }, { '4' }, { '5' } }
    )
  end)
  it('util topo_sort complex dependency', function()
    local sorter = topo_sort:new(function(_, v)
      return v[1]
    end, function(v)
      return fn.with_default {}(v.after)
    end)
    assert.same(
      { { '1' }, { '4' }, { '5' }, { '3', after = { '5' } }, { '2', after = { '3' } } },
      sorter:sort { { '1' }, { '2', after = { '3' } }, { '3', after = { '5' } }, { '4' }, { '5' } }
    )
  end)
  it('util topo_sort complex dependency with circle', function()
    local sorter = topo_sort:new(function(_, v)
      return v[1]
    end, function(v)
      return fn.with_default {}(v.after)
    end)
    local sorteds =
      sorter:sort { { '1' }, { '2', after = { '3' } }, { '3', after = { '5' } }, { '4' }, { '5', after = { '2' } } }
    assert.same({ { '1' }, { '4' } }, { sorteds[1], sorteds[2] })
  end)
end)
