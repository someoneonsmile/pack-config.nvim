local M = {}

M.name = 'paq'


M.exist = function()
  return pcall(require, 'paq')
end


local transform = function(pack)
  return pack
end


-- @param packs table
--  pack = {'', as = '', ft = {}, opt = true, run = function() end}
M.load = function(packs)
  local ok, paq = pcall(require, 'paq')
  if not ok then
    error('not find paq.nvim')
  end
  paq(vim.tbl_map(transform, packs))
end

return M
