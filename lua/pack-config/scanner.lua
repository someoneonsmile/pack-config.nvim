local convert = require('pack-config.util').convert
local builtin_scanners = function()
  return {
    require('pack-config.scanner.fd'),
    require('pack-config.scanner.uv'),
  }
end

local available_builtin_scanners = function()
  return vim.tbl_filter(function(scanner)
    return convert.to_bool(scanner.exist)
  end, builtin_scanners())
end

local with_default = function(scanner, report_error)
  if scanner ~= nil then
    if not scanner.exist() and report_error then
      error(string.format('the scanner not exist, %s', scanner.name))
    end
    return scanner
  end
  local scanners = builtin_scanners()
  local scanner_names = vim.tbl_map(function(it)
    return it.name
  end, scanners)

  local available_scanners = available_builtin_scanners()

  if vim.tbl_isempty(available_scanners) then
    if report_error then
      error(string.format(
        [[there is no pack scanner available here.
        if use the builtin scanner please make sure to download them before
        builtin_scanners: %s]],
        table.concat(scanner_names, ', ')
      ))
    end
    return scanners[1]
  else
    return available_scanners[1]
  end
end

local M = setmetatable({
  builtin_scanners = builtin_scanners,
  available_builtin_scanners = available_builtin_scanners,
  with_default = with_default,
}, {
  __index = function(self, k)
    local v = require('pack-config.scanner.' .. k)
    self[k] = v
    return v
  end,
})

return M
