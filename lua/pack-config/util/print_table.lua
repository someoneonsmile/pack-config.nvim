local fill_space = function(s, least)
  if least > #s then
    local half = math.ceil((least - #s) / 2)
    return string.rep(' ', half) .. s .. string.rep(' ', least - #s - half)
  end
  return s
end

local get_head_str = function(col_indexs, col_maxs)
  local fill_row = {}
  for _, col_index in ipairs(col_indexs) do
    table.insert(fill_row, fill_space(col_index, col_maxs[col_index]))
  end
  return '| ' .. table.concat(fill_row, ' | ') .. ' |'
end

local get_separator_str = function(col_indexs, col_maxs)
  local fill_row = {}
  for _, col_index in ipairs(col_indexs) do
    table.insert(fill_row, string.rep('-', col_maxs[col_index]))
  end
  return '| ' .. table.concat(fill_row, ' | ') .. ' |'
end

local get_row_str = function(row, col_indexs, col_maxs)
  local fill_row = {}
  for _, col_index in ipairs(col_indexs) do
    table.insert(fill_row, fill_space(tostring(row[col_index]), col_maxs[col_index]))
  end
  return '| ' .. table.concat(fill_row, ' | ') .. ' |'
end

local M = {}

M.new = function(col_indexs, rows)
  local o = {}
  o.col_indexs = col_indexs
  o.rows = rows
  local col_maxs = {}
  for _, row in ipairs(rows) do
    for _, col_index in ipairs(col_indexs) do
      col_maxs[col_index] = math.max(col_maxs[col_index] or #col_index, #tostring(row[col_index]))
    end
  end
  o.col_maxs = col_maxs

  return setmetatable(o, M)
end

M.__tostring = function(self)
  local t = {}
  table.insert(t, get_head_str(self.col_indexs, self.col_maxs))
  table.insert(t, get_separator_str(self.col_indexs, self.col_maxs))
  for _, row in ipairs(self.rows) do
    if row.type == 'separator' then
      table.insert(t, get_separator_str(self.col_indexs, self.col_maxs))
    else
      table.insert(t, get_row_str(row, self.col_indexs, self.col_maxs))
    end
  end
  table.insert(t, get_separator_str(self.col_indexs, self.col_maxs))
  return table.concat(t, '\n')
end

return M
