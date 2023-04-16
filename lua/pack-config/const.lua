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
}

return M
