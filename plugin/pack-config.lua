if vim.g.loaded_pack_config == 1 then
  return
end
vim.g.loaded_pack_config = 1

-- create command
vim.api.nvim_create_user_command('PackProfileReport', function()
  require('pack-config.profile').report()
end, {})
