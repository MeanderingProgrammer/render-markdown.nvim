local source = require('render-markdown.integ.source')

---@class render.md.cmp.Coq
local M = {}

---@private
---@type boolean
M.initialized = false

---called from manager on buffer attach or directly by user
function M.setup()
    if M.initialized then
        return
    end
    M.initialized = true
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
