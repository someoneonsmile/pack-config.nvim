local M = {}

M.sort = function(tbl, key_extrator)
  return table.sort(tbl, function(item1, item2)
    return key_extrator(item1) < key_extrator(item2)
  end)
end

return M
