local source = require('render-markdown.integ.source')

local M = {}

---@class coq.Args
---@field pos {[1]: integer, [2]:integer}
---@field line string

---@class coq.CallbackArgs
---@field isIncomplete boolean
---@field items vim.lsp.CompletionResult

---@class coq.Source
---@field name string
---@field fn fun(args: coq.Args, callback: fun(args?: coq.CallbackArgs)): fun()|nil

---@alias coq.Sources table<integer, coq.Source>

---@param map coq.Sources
local function new_uid(map)
    local key ---@type integer|nil
    while true do
        if not key or map[key] then
            key = math.floor(math.random() * 10000)
        else
            return key
        end
    end
end

local function complete(args, callback)
    if not source.enabled() then
        callback(nil)
        return
    end

    local last_char = args.line:sub(#args.line, #args.line)
    if not vim.list_contains(source:trigger_characters(), last_char) then
        callback(nil)
        return
    end

    local row, col = unpack(args.pos) ---@type integer, integer

    local items = source.items(0, row, col)

    if items == nil then
        callback(nil)
        return
    end

    callback(items)
end

---Should only be called by a user to enable the integration
function M.setup()
    local has_coq = pcall(require, 'coq')
    if not has_coq then
        return
    end
    COQsources = COQsources or {} ---@type coq.Sources
    COQsources[new_uid(COQsources)] = {
        name = 'rMD',
        fn = complete,
    }
end

return M
