local api = require('render-markdown.api')

local name = 'RenderMarkdown'
local plugin = 'render-markdown.nvim'
---@type table<string, type?>
local method_args = {
    set = 'boolean',
    set_buf = 'boolean',
}
---@type string[]
local code_only = { 'render' }

---@class render.md.Command
local M = {}

---called from plugin directory
function M.init()
    vim.api.nvim_create_user_command(name, M.command, {
        nargs = '*',
        desc = plugin .. ' commands',
        ---@param cmdline string
        ---@param col integer
        ---@return string[]
        complete = function(_, cmdline, col)
            local line = cmdline:sub(1, col):match('^' .. name .. '%s+(.*)$')
            if line then
                local fargs = vim.split(line, '%s+')
                if #fargs == 1 then
                    return M.matches(fargs[1], vim.tbl_keys(api), code_only)
                elseif #fargs == 2 then
                    local arg = method_args[fargs[1]]
                    if arg == 'boolean' then
                        return M.matches(fargs[2], { 'true', 'false' }, {})
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
---@param skip string[]
---@return string[]
function M.matches(prefix, values, skip)
    local result = {} ---@type string[]
    for _, value in ipairs(values) do
        if not vim.tbl_contains(skip, value) then
            if vim.startswith(value, prefix) then
                result[#result + 1] = value
            end
        end
    end
    return result
end

---@private
---@param args vim.api.keyset.create_user_command.command_args
function M.command(args)
    local err = M.run(args.fargs)
    if err then
        vim.notify(('%s: %s'):format(plugin, err), vim.log.levels.ERROR)
    end
end

---@private
---@param fargs string[]
---@return string?
function M.run(fargs)
    if #fargs > 2 then
        return ('invalid # arguments - %d'):format(#fargs)
    end
    local method = fargs[1] or 'enable'
    local command = api[method] --[[@as fun(enable?: boolean)?]]
    if not command or vim.tbl_contains(code_only, method) then
        return ('invalid command - %s'):format(method)
    end
    if #fargs == 2 then
        local arg = method_args[method]
        local value = fargs[2]
        if not arg then
            return ('no arguments allowed - %s'):format(method)
        elseif arg == 'boolean' then
            if value == 'true' then
                command(true)
            elseif value == 'false' then
                command(false)
            else
                return ('invalid argument - %s(%s)'):format(method, value)
            end
        else
            return ('bug unhandled type - %s'):format(arg)
        end
    else
        command()
    end
end

return M
