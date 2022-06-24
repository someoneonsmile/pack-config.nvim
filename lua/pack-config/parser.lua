local convert = require('pack-config.util').convert
local builtin_parsers = function()
  return {
    require('pack-config.parser.lua'),
  }
end

local available_builtin_parsers = function()
  return vim.tbl_filter(function(parser)
    return convert.to_bool(parser.exist)
  end, builtin_parsers())
end

local with_default = function(parser, report_error)
  if parser ~= nil then
    if not parser.exist() and report_error then
      error(string.format('the parser not exist, %s', parser.name))
    end
    return parser
  end
  local parsers = builtin_parsers()

  local available_parsers = available_builtin_parsers()

  if vim.tbl_isempty(available_parsers) then
    if report_error then
      error([[there is no pack parser available here.]])
    end
    return parsers[1]
  else
    return available_parsers[1]
  end
end

local M = setmetatable({
  builtin_parsers = builtin_parsers,
  available_builtin_parsers = available_builtin_parsers,
  with_default = with_default,
}, {
  __index = function(self, k)
    local v = require('pack-config.parser.' .. k)
    self[k] = v
    return v
  end,
})

return M
