local source = require('render-markdown.integ.source')

---@class render.md.cmp.Coq
---@field private registered boolean
local M = {
    registered = false,
}

---Should only be called from manager on initial buffer attach
---or by a user to enable the integration
function M.setup()
    if M.registered then
        return
    end
    M.registered = true
    local has_coq = pcall(require, 'coq')
    if not has_coq then
        return
    end
    ---@type table<integer, table>
    COQsources = COQsources or {}
    COQsources[M.new_uid(COQsources)] = {
        name = 'markdown',
        fn = M.complete,
    }
end

---@private
---@param map table<integer, table>
---@return integer
function M.new_uid(map)
    local key = nil ---@type integer?
    while true do
        if not key or map[key] then
            key = math.floor(math.random() * 10000)
        else
            return key
        end
    end
end

---@private
---@param args { line: string, pos: { [1]: integer, [2]: integer } }
---@param callback fun(response?: lsp.CompletionItem[])
function M.complete(args, callback)
    ---@return lsp.CompletionItem[]?
    local function get_items()
        if not source.enabled() then
            return nil
        end
        local character = args.line:sub(args.pos[2], args.pos[2])
        if not vim.tbl_contains(source.trigger_characters(), character) then
            return nil
        end
        return source.items(0, args.pos[1], args.pos[2])
    end
    callback(get_items())
end

return M
