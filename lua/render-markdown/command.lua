local api = require('render-markdown.api')

---@class render.md.Command
local M = {}

---@private
M.name = 'RenderMarkdown'

---@private
M.plugin = 'render-markdown.nvim'

local starts_with = function(str, start)
    return str:sub(1, #start) == start
end

local get_matching_values = function(value, potential_values)
    local matching_values = {}
    for _, potential_value in ipairs(potential_values) do
        if starts_with(potential_value, value) then
            table.insert(matching_values, potential_value)
        end
    end
    return matching_values
end

---Should only be called from plugin directory
function M.setup()
    vim.api.nvim_create_user_command(M.name, M.command, {
        nargs = '*',
        desc = M.plugin .. ' commands',
        complete = function(ArgLead, cmdline)
            if cmdline:find(M.name .. '%s+%S+%s+.*') then
                return {}
            elseif cmdline:find(M.name .. '%s+') then
                return get_matching_values(ArgLead, vim.tbl_keys(api))
            else
                return {}
            end
        end,
    })
end

---@private
---@param opts { fargs: string[] }
function M.command(opts)
    local args, message = opts.fargs, nil
    if #args == 0 or #args == 1 then
        local command = #args == 0 and api.enable or api[args[1]]
        if command ~= nil then
            command()
        else
            message = string.format('unexpected command: %s', args[1])
        end
    else
        message = string.format('unexpected # arguments: %d', #args)
    end
    if message ~= nil then
        vim.notify(string.format('%s: %s', M.plugin, message), vim.log.levels.ERROR)
    end
end

return M
