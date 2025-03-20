---@module 'blink.cmp'

local source = require('render-markdown.integ.source')
local state = require('render-markdown.state')

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
    -- nvim_win_get_cursor: (1,0)-indexed
    local cursor = context.cursor
    local items = source.items(context.bufnr, cursor[1] - 1, cursor[2])
    if items == nil then
        callback(nil)
    else
        callback({
            is_incomplete_forward = false,
            is_incomplete_backward = false,
            items = items,
        })
    end
end

---@class render.md.integ.Blink
---@field private id string
---@field private registered boolean
local M = {
    id = 'markdown',
    registered = false,
}

---Should only be called from manager on initial buffer attach
function Source.setup()
    if M.registered then
        return
    end
    M.registered = true
    local has_blink, blink = pcall(require, 'blink.cmp')
    if not has_blink or blink == nil then
        return
    end
    pcall(blink.add_source_provider, M.id, {
        name = 'RenderMarkdown',
        module = 'render-markdown.integ.blink',
    })
    for _, file_type in ipairs(state.file_types) do
        pcall(blink.add_filetype_source, file_type, M.id)
    end
end

return Source
