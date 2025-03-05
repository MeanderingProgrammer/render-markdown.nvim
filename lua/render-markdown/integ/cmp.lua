local source = require('render-markdown.integ.source')

---@class render.md.cmp.Source: cmp.Source
local Source = {}

---@return string
function Source:get_debug_name()
    return 'render-markdown'
end

---@return boolean
function Source:is_available()
    return source.enabled()
end

---@return string[]
function Source:get_trigger_characters()
    return source.trigger_characters()
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response?: lsp.CompletionItem[])
function Source:complete(params, callback)
    local context = params.context
    -- nvim_win_get_cursor: (1,0)-indexed
    -- nvim-cmp col + 1   : (1,1)-indexed
    local cursor = context.cursor
    local items = source.items(context.bufnr, cursor.row - 1, cursor.col - 1)
    callback(items)
end

---@class render.md.integ.Cmp
---@field private registered boolean
local M = {
    registered = false,
}

---Should only be called from manager on initial buffer attach
function M.setup()
    if M.registered then
        return
    end
    M.registered = true
    local has_cmp, cmp = pcall(require, 'cmp')
    if not has_cmp then
        return
    end
    pcall(cmp.register_source, Source:get_debug_name(), Source)
end

return M
