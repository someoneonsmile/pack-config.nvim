local M = {}


local context = {}

local default_opts = {
    prefx = '',
    override = false
}


M.set = function(key, value, opts)

    opts = vim.tbl_deep_extend('force', default_opts, opts or {})

    local prefix = opts.prefix or ''
    context[prefix] = context[prefix] or {}
    local config = context[prefix]

    if config[key] then
        if opts.override then
            config[key] = value
            return true
        else
            return false
        end
    end

    config[key] = value
    return true
end


M.get = function(key, opts)
    opts = vim.tbl_deep_extend('force', default_opts, opts or {})
    return context[opts.prefix][key]
end

return M

