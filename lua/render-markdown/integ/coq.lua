local source = require('render-markdown.integ.source')

---@param map table<integer, table>
---@return integer
local function new_uid(map)
    ---@type integer|nil
    local key = nil
    while true do
        if not key or map[key] then
            key = math.floor(math.random() * 10000)
        else
            return key
        end
    end
end

---@param args { line: string, pos: { [1]: integer, [2]: integer } }
---@param callback fun(response?: lsp.CompletionItem[])
local function complete(args, callback)
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

---@class render.md.cmp.Coq
local M = {}

---Should only be called by a user to enable the integration
function M.setup()
    local has_coq = pcall(require, 'coq')
    if not has_coq then
        return
    end
    ---@type table<integer, table>
    COQsources = COQsources or {}
    COQsources[new_uid(COQsources)] = {
        name = 'markdown',
        fn = complete,
    }
end

return M
