local api = require('render-markdown.api')

---@class render.md.Command
local M = {}

---@private
M.name = 'RenderMarkdown'

---@private
M.plugin = 'render-markdown.nvim'

---Should only be called from plugin directory
function M.setup()
    vim.api.nvim_create_user_command(M.name, M.command, {
        nargs = '*',
        desc = M.plugin .. ' commands',
        complete = function(prefix, cmdline)
            if cmdline:find(M.name .. '%s+%S+%s+.*') then
                return {}
            elseif cmdline:find(M.name .. '%s+') then
                return M.matches(prefix, vim.tbl_keys(api))
            else
                return {}
            end
        end,
    })
end

---@private
---@param opts { fargs: string[] }
function M.command(opts)
    local args, err = opts.fargs, nil
    if #args == 0 or #args == 1 then
        local command = #args == 0 and api.enable or api[args[1]]
        if command ~= nil then
            command()
        else
            err = string.format('unexpected command: %s', args[1])
        end
    else
        err = string.format('unexpected # arguments: %d', #args)
    end
    if err ~= nil then
        vim.notify(string.format('%s: %s', M.plugin, err), vim.log.levels.ERROR)
    end
end

---@private
---@param prefix string
---@param values string[]
---@return string[]
function M.matches(prefix, values)
    local result = {}
    for _, value in ipairs(values) do
        if vim.startswith(value, prefix) then
            result[#result + 1] = value
        end
    end
    return result
end

return M
