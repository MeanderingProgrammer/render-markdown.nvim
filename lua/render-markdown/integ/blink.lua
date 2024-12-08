---@module 'blink.cmp'

local source = require('render-markdown.integ.source')

---@class render.md.blink.Source: blink.cmp.Source
local Source = {}
Source.__index = Source

---@return blink.cmp.Source
function Source.new()
    return setmetatable({}, Source)
end

---@return boolean
function Source:enabled()
    return source.enabled()
end

---@return string[]
function Source:get_trigger_characters()
    return source.trigger_characters()
end

---@param context blink.cmp.Context
---@param callback fun(response?: blink.cmp.CompletionResponse)
function Source:get_completions(context, callback)
    local items = source.items(context.bufnr, context.cursor[1] - 1, context.cursor[2] - 1)
    if items == nil then
        callback(nil)
    else
        callback({
            is_incomplete_forward = false,
            is_incomplete_backward = false,
            context = context,
            items = items,
        })
    end
end

return Source
