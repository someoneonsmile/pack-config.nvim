local M = {}

M.name = 'packer'


M.exist = function()
  return pcall(require, 'packer')
end


local transform = function(pack)
  -- TODO:  unimplement
end


-- @param packs table
--  pack = {'', as = '', ft = {}, opt = true, run = function() end}
M.load = function(packs)
  local ok, packer = pcall(require, 'packer')
  if not ok then
    error('not find paq.nvim')
  end
  packer.startup(function(use)
    for _, pack in ipairs(packs) do
      use(transform(pack))
    end
  end)
end

return M
