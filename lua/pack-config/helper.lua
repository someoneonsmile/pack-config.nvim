local util = require('pack-config.util')
local log = require('pack-config.log')
local Set = util.set
local Convert = util.convert

local M = {}

M.answer = function(question, answers)
  answers = Set.from_list(Convert.to_table(answers or { 'y', 'yes' }))
  local input = vim.fn.input(question)
  return Set.contains(answers, input)
end

-- ----------------------------------------------------------------------
--    - download -
-- ----------------------------------------------------------------------

-- @param pack
--  pack.dest_dir string dest dir
--  pack.prompt tip to user
--  pack.name
--  pack.path pack path
--  pack.temp true: pack will clean when nvim exit
M.download_pack = function(pack)
  vim.fn.mkdir(pack.dist_dir, 'p')
  if not vim.endswith(pack.dist_dir, '/') then
    pack.dist_dir = pack.dist_dir .. '/'
  end
  if pack.prompt and M.answer(pack.prompt .. ' [y/N]: ') then
    local clone_cmd = {
      'git',
      'clone',
      '--filter=blob:none',
      string.format('https://github.com/%s.git', pack.path),
      pack.dist_dir .. pack.name,
    }
    log.info(clone_cmd)
    local out = vim.fn.system(clone_cmd)
    log.info(out)
    local r = vim.v.shell_error == 0
    if r and pack.temp then
      vim.api.nvim_create_autocmd('VimLeave', {
        callback = function()
          vim.fn.system(string.format('rm -r %s', pack.dist_dir .. pack.name))
        end,
      })
    end
    return r
  end
  return false
end

M.is_pack_exists = function(pack)
  if pcall(require, pack) then
    return true
  end
  pcall(vim.cmd, 'packadd! ' .. pack)
  return pcall(require, pack)
end

return M
