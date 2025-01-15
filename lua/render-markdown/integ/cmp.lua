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
    local items = source.items(context.bufnr, context.cursor.row - 1, context.cursor.col - 1)
    callback(items)
end

---@class render.md.integ.Cmp
local M = {}

---Should only be called from plugin directory
function M.setup()
    local has_cmp, cmp = pcall(require, 'cmp')
    if not has_cmp then
        return
    end
    pcall(cmp.register_source, Source:get_debug_name(), Source)
end

return M
