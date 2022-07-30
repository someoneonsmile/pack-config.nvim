local Context = require('pack-config.context')
local Const = require('pack-config.const')
local util = require('pack-config.util')

local Pt = util.print_table
local tbl = util.tbl

local this = {
  clock = function()
    return vim.loop.hrtime() / 1000000
  end,
  context = Context:new(Const.profile_key),
}

local M = {}

M.setclock = function(clock)
  this.clock = clock
end

M.start = function(group_key, item_key)
  this.context[group_key] = this.context[group_key] or {}
  this.context[group_key][item_key] = { start = this.clock() }
end

M.stop = function(group_key, item_key)
  local item = this.context[group_key][item_key]
  item.stop = this.clock()
  item.time = item.stop - item.start
end

M.report = function()
  local rows = {}
  for group_key, group in pairs(this.context) do
    local group_rows = {}
    for item_key, item in pairs(group) do
      table.insert(group_rows, { group = group_key, item = item_key, time = item.time })
    end
    table.sort(group_rows, function(a, b)
      return a.time > b.time
    end)
    for index, group_row in ipairs(group_rows) do
      group_row.index = tostring(index)
      group_row.time = string.format('%.2f', group_row.time)
    end
    table.insert(group_rows, { type = 'separator' })
    tbl.list_extend(rows, group_rows)
  end

  local pt = Pt.new({ 'index', 'group', 'item', 'time' }, rows)
  print(pt)
end

return M
