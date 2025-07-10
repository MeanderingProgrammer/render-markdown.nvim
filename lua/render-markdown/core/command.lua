local api = require('render-markdown.api')

---@class render.md.Command
local M = {}

---@private
M.name = 'RenderMarkdown'

---@private
M.plugin = 'render-markdown.nvim'

---@private
---@type table<string, type?>
M.args = {
    set = 'boolean',
    set_buf = 'boolean',
}

---called from plugin directory
function M.init()
    vim.api.nvim_create_user_command(M.name, M.command, {
        nargs = '*',
        desc = M.plugin .. ' commands',
        complete = function(_, cmdline, col)
            local line = cmdline:sub(1, col):match('^' .. M.name .. '%s+(.*)$')
            if line then
                local fargs = vim.split(line, '%s+')
                if #fargs == 1 then
                    return M.matches(fargs[1], vim.tbl_keys(api))
                elseif #fargs == 2 then
                    local arg = M.args[fargs[1]]
                    if arg == 'boolean' then
                        return M.matches(fargs[2], { 'true', 'false' })
                    end
                end
            end
            return {}
        end,
    })
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

---@private
---@param args vim.api.keyset.create_user_command.command_args
function M.command(args)
    local err = M.run(args.fargs)
    if err then
        vim.notify(('%s: %s'):format(M.plugin, err), vim.log.levels.ERROR)
    end
end

---@private
---@param fargs string[]
---@return string?
function M.run(fargs)
    if #fargs > 2 then
        return ('invalid # arguments - %d'):format(#fargs)
    end
    local name = fargs[1] or 'enable'
    local command = api[name]
    if not command then
        return ('invalid command - %s'):format(name)
    end
    if #fargs == 2 then
        local arg = M.args[name]
        local value = fargs[2]
        if not arg then
            return ('no arguments allowed - %s'):format(name)
        elseif arg == 'boolean' then
            if value == 'true' then
                command(true)
            elseif value == 'false' then
                command(false)
            else
                return ('invalid argument - %s(%s)'):format(name, value)
            end
        else
            return ('bug unhandled type - %s'):format(arg)
        end
    else
        command()
    end
end

return M
