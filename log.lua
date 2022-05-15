-- log.lua
--
-- Inspired by rxi/log.lua
-- Modified by tjdevries and can be found at github.com/tjdevries/vlog.nvim
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

local p_debug = vim.fn.getenv('DEBUG_PLENARY')
if p_debug == vim.NIL then
  p_debug = false
end

-- User configuration section
local default_config = {
  -- Name of the plugin. Prepended to log messages
  plugin = 'pack-config',

  -- Should highlighting be used in console (using echohl)
  highlights = true,

  info_level = 2,

  endpoint = {
    use_console = {
      enable = false,
      level = 'info',
      async = true,
    },
    use_notify = {
      enable = true,
      level = 'info',
      async = true,
    },
    use_file = {
      enable = true,
      level = 'debug',
    },
    use_quickfix = false,
  },

  -- Level configuration
  modes = {
    { name = 'trace', hl = 'Comment', log_level = vim.log.levels.TRACE },
    { name = 'debug', hl = 'Comment', log_level = vim.log.levels.DEBUG },
    { name = 'info', hl = 'None', log_level = vim.log.levels.INFO },
    { name = 'warn', hl = 'WarningMsg', log_level = vim.log.levels.WARN },
    { name = 'error', hl = 'ErrorMsg', log_level = vim.log.levels.ERROR },
    { name = 'fatal', hl = 'ErrorMsg', log_level = vim.log.levels.ERROR },
  },

  -- Can limit the number of decimals displayed for floats
  float_precision = 0.01,
}

-- {{{ NO NEED TO CHANGE
local Log = {}

local unpack = unpack or table.unpack

local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
end

local make_string = function(config, ...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)

    if type(x) == 'number' and config.float_precision then
      x = tostring(round(x, config.float_precision))
    elseif type(x) == 'table' then
      x = vim.inspect(x)
    else
      x = tostring(x)
    end

    t[#t + 1] = x
  end
  return table.concat(t, ' ')
end

-- ----------------------------------------------------------------------
--    - endpoint deal logic -
-- ----------------------------------------------------------------------

local endpoint_handles = {
  use_console = {
    support = function(config, log_level)
      local endpoint_config = config.endpoint.use_console
      return endpoint_config and endpoint_config.enable and log_level >= config.levels[endpoint_config.level]
    end,
    handle = function(config, level_config, msg, lineinfo, info)
      -- log to console function
      --
      local log_to_console = function()
        local console_string = string.format(
          '[%-6s%s] %s: %s',
          level_config.name:upper(),
          os.date('%H:%M:%S'),
          lineinfo,
          msg
        )

        if config.highlights and level_config.hl then
          vim.cmd(string.format('echohl %s', level_config.hl))
        end

        local split_console = vim.split(console_string, '\n')
        for _, v in ipairs(split_console) do
          local formatted_msg = string.format('[%s] %s', config.plugin, vim.fn.escape(v, [["\]]))

          local ok = pcall(vim.cmd, string.format([[echom "%s"]], formatted_msg))
          if not ok then
            vim.api.nvim_out_write(msg .. '\n')
          end
        end

        if config.highlights and level_config.hl then
          vim.cmd('echohl NONE')
        end
      end

      -- deal for async flag
      if not config.endpoint.use_console.async and not vim.in_fast_event() then
        log_to_console()
      else
        vim.schedule(log_to_console)
      end
    end,
  },
  use_notify = {
    support = function(config, log_level)
      local endpoint_config = config.endpoint.use_notify
      return endpoint_config and endpoint_config.enable and log_level >= config.levels[endpoint_config.level]
    end,
    handle = function(config, level_config, msg, lineinfo, info)
      local notify = function()
        local formatted_msg = string.format('[%s] %s: %s', config.plugin, lineinfo, msg)
        vim.notify(formatted_msg, level_config.log_level)
      end

      -- deal for async flag
      if not config.endpoint.use_notify.async and not vim.in_fast_event() then
        notify()
      else
        vim.schedule(notify)
      end
    end,
  },
  use_file = {
    support = function(config, log_level)
      local endpoint_config = config.endpoint.use_file
      return endpoint_config and endpoint_config.enable and log_level >= config.levels[endpoint_config.level]
    end,
    handle = function(config, level_config, msg, lineinfo, info)
      local outfile = string.format('%s/%s.log', vim.fn.stdpath('cache'), config.plugin)
      local fp = assert(io.open(outfile, 'a'))
      local str = string.format('[%-6s%s] %s: %s\n', level_config.name:upper(), os.date(), lineinfo, msg)
      fp:write(str)
      fp:close()
    end,
  },
  use_quickfix = {
    support = function(config, log_level)
      local endpoint_config = config.endpoint.use_quickfix
      return endpoint_config and endpoint_config.enable and log_level >= config.levels[endpoint_config.level]
    end,
    handle = function(config, level_config, msg, lineinfo, info)
      local formatted_msg = string.format('[%s] %s', level_config.name:upper(), msg)
      local qf_entry = {
        -- remove the @ getinfo adds to the file path
        filename = info.source:sub(2),
        lnum = info.currentline,
        col = 1,
        text = formatted_msg,
      }
      vim.fn.setqflist({ qf_entry }, 'a')
    end,
  },
}

-- ----------------------------------------------------------------------
--    - deal log -
-- ----------------------------------------------------------------------

local log_at_level = function(config, level, level_config, message_maker, ...)
  local available_handlers = {}
  for k, handler in pairs(endpoint_handles) do
    if handler.support(config, level) then
      available_handlers[k] = handler
    end
  end

  -- Return early if no available handlers
  if vim.tbl_isempty(available_handlers) then
    return
  end

  local msg = message_maker(config, ...)
  local info = debug.getinfo(config.info_level or 2, 'Sl')
  local lineinfo = info.short_src .. ':' .. info.currentline

  for _, handler in pairs(available_handlers) do
    handler.handle(config, level_config, msg, lineinfo, info)
  end
end

-- ----------------------------------------------------------------------
--    - generate config level log method -
-- ----------------------------------------------------------------------

local make_log_method = function(obj)
  local config = obj.config
  for i, x in ipairs(config.modes) do
    -- log.info("these", "are", "separated")
    obj[x.name] = function(...)
      return log_at_level(config, i, x, make_string, ...)
    end

    -- log.fmt_info("These are %s strings", "formatted")
    obj[('fmt_%s'):format(x.name)] = function(...)
      return log_at_level(config, i, x, function(...)
        local passed = { ... }
        local fmt = table.remove(passed, 1)
        local inspected = {}
        for _, v in ipairs(passed) do
          table.insert(inspected, vim.inspect(v))
        end
        return string.format(fmt, unpack(inspected))
      end, ...)
    end

    -- log.lazy_info(expensive_to_calculate)
    obj[('lazy_%s'):format(x.name)] = function(f)
      return log_at_level(config, i, x, function(_, i_f)
        return i_f()
      end, f)
    end

    -- log.file_info("do not print")
    obj[('file_%s'):format(x.name)] = function(vals, override)
      local merge_config = vim.tbl_deep_extend('force', config, override, { endpoint = { use_console = false } })
      log_at_level(merge_config, i, x, make_string, unpack(vals))
    end
  end
  obj.log = function(log_level, ...)
    return log_at_level(config, config.levels[log_level], config.modes[config.levels[log_level]], make_string, ...)
  end
end

Log.new = function(config, standalone)
  config = vim.tbl_deep_extend('force', default_config, config)

  local levels = {}
  for i, v in ipairs(config.modes) do
    levels[v.name] = i
    levels[v.log_level] = i
  end
  config.levels = levels

  local obj
  if standalone then
    obj = Log
  else
    obj = {}
  end
  obj.config = config

  make_log_method(obj)

  return obj
end

Log.new(default_config, true)
-- }}}

return Log
