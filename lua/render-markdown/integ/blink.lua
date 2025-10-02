local source = require('render-markdown.integ.source')
local state = require('render-markdown.state')

---@class render.md.blink.Source: blink.cmp.Source
local Source = {}
Source.__index = Source

---@private
---@type boolean
Source.initialized = false

---called from manager on buffer attach
function Source.init()
    if Source.initialized then
        return
    end
    Source.initialized = true
    local has_blink, blink = pcall(require, 'blink.cmp')
    if not has_blink or not blink then
        return
    end
    local id = 'markdown'
    pcall(blink.add_source_provider, id, {
        name = 'RenderMarkdown',
        module = 'render-markdown.integ.blink',
    })
    for _, file_type in ipairs(state.file_types) do
        pcall(blink.add_filetype_source, file_type, id)
    end
end

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
    if not items then
        callback(nil)
    else
        callback({
            is_incomplete_forward = false,
            is_incomplete_backward = false,
            items = items,
        })
    end
end

return Source
