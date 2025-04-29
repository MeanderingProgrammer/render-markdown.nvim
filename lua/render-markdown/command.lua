local api = require('render-markdown.api')

---@class render.md.Command
local M = {}

---@private
M.name = 'RenderMarkdown'

---@private
M.plugin = 'render-markdown.nvim'

---called from plugin directory
function M.init()
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
---@param args vim.api.keyset.create_user_command.command_args
function M.command(args)
    local fargs, err = args.fargs, nil
    if #fargs == 0 or #fargs == 1 then
        local command = #fargs == 0 and api.enable or api[fargs[1]]
        if command then
            command()
        else
            err = ('unexpected command: %s'):format(fargs[1])
        end
    else
        err = ('unexpected # arguments: %d'):format(#fargs)
    end
    if err then
        vim.notify(('%s: %s'):format(M.plugin, err), vim.log.levels.ERROR)
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
