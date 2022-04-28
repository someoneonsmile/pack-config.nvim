local builtin_scanners = function()
  return {
    -- TODO:  adjust the order
    require('pack-config.scanner.builtin.fd'),
    require('pack-config.scanner.builtin.uv'),
  }
end


local available_builtin_scanners = function()
  return vim.tbl_filter(function(scanner)
    return scanner.exist()
  end, builtin_scanners())
end


local with_default = function(scanner, report_error)
  if scanner ~= nil and scanner.exsit() then
    return scanner
  end
  local scanners = builtin_scanners()
  local scanner_names = vim.tbl_map(function(it) return it.name end, scanners)

  local available_scanners = available_builtin_scanners()

  if vim.tbl_isempty(available_scanners) then
    if report_error then
      error(string.format([[there is no pack scanner available here.
        if use the builtin scanner please make sure to download them before
        builtin_scanners: %s]], table.concat(scanner_names, ', ')))
    end
  else
    return available_scanners[1]
  end
end


local M = {
  builtin_scanners = builtin_scanners,
  available_builtin_scanners = available_builtin_scanners,
  with_default = with_default,
}

return M
