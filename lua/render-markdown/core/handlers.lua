local log = require('render-markdown.core.log')

---@class render.md.handlers.Config
---@field custom table<string, render.md.Handler>

---@class render.md.Handlers
---@field private config render.md.handlers.Config
local M = {}

---@private
---@type table<string, render.md.Handler>
M.builtin = {
    html = require('render-markdown.handler.html'),
    latex = require('render-markdown.handler.latex'),
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    yaml = require('render-markdown.handler.yaml'),
}

---called from state on setup
---@param config render.md.handlers.Config
function M.setup(config)
    M.config = config
end

---@param context render.md.request.Context
---@param parser vim.treesitter.LanguageTree
---@return render.md.Mark[]
function M.run(context, parser)
    local marks = {} ---@type render.md.Mark[]
    -- parse markdown after other nodes to get accurate state
    local markdown = {} ---@type render.md.handler.Context[]
    parser:for_each_tree(function(tree, language_tree)
        ---@type render.md.handler.Context
        local ctx = { buf = context.buf, root = tree:root() }
        local language = language_tree:lang()
        if language == 'markdown' then
            markdown[#markdown + 1] = ctx
        else
            vim.list_extend(marks, M.tree(context, ctx, language))
        end
    end)
    for _, ctx in ipairs(markdown) do
        vim.list_extend(marks, M.tree(context, ctx, 'markdown'))
    end
    return marks
end

---Run custom & builtin handlers when available. Custom handler is always
---executed, builtin handler is skipped if custom does not specify extends.
---@private
---@param context render.md.request.Context
---@param ctx render.md.handler.Context
---@param language string
---@return render.md.Mark[]
function M.tree(context, ctx, language)
    log.buf('trace', 'Language', ctx.buf, language)
    if not context.view:overlaps(ctx.root) then
        return {}
    end
    local marks = {} ---@type render.md.Mark[]
    local custom = M.config.custom[language]
    if custom then
        log.buf('trace', 'Handler', ctx.buf, 'custom')
        vim.list_extend(marks, custom.parse(ctx))
        if not custom.extends then
            return marks
        end
    end
    local builtin = M.builtin[language]
    if builtin then
        log.buf('trace', 'Handler', ctx.buf, 'builtin')
        vim.list_extend(marks, builtin.parse(ctx))
    end
    return marks
end

return M
