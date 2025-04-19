local M = {}

local key_prefix = 'pack-config.'
M.key = {
  pack_context = key_prefix .. 'pack_context',
  util_fn_once = key_prefix .. 'util.fn',
  util_id = key_prefix .. 'util.id',
  profile = key_prefix .. 'profile',
}

M.path = {
  init_pack = vim.fn.stdpath('data') .. '/site/pack/init/start/',
  init_pack_opt = vim.fn.stdpath('data') .. '/site/pack/init/opt/',
}

M.self_pack_name = 'someoneonsmile/pack-config.nvim'

return M
