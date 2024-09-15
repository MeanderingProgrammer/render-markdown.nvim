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
        complete = function(_, cmdline)
            if cmdline:find(M.name .. '%s+%S+%s+.*') then
                return {}
            elseif cmdline:find(M.name .. '%s+') then
                return vim.tbl_keys(api)
            else
                return {}
            end
        end,
    })
end

---@private
---@param opts { fargs: string[] }
function M.command(opts)
    local args, error_message = opts.fargs, nil
    if #args == 0 or #args == 1 then
        local command = #args == 0 and api.enable or api[args[1]]
        if command ~= nil then
            command()
        else
            error_message = string.format('unexpected command: %s', args[1])
        end
    else
        error_message = string.format('unexpected # arguments: %d', #args)
    end
    if error_message ~= nil then
        vim.notify(string.format('%s: %s', M.plugin, error_message), vim.log.levels.ERROR)
    end
end

return M
