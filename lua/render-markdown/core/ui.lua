local Buffer = require('render-markdown.core.buffer')
local Compat = require('render-markdown.lib.compat')
local Context = require('render-markdown.core.context')
local Env = require('render-markdown.lib.env')
local Extmark = require('render-markdown.core.extmark')
local Iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

---@class (exact) render.md.Handler
---@field extends? boolean
---@field parse fun(ctx: render.md.handler.Context): render.md.Mark[]

---@class (exact) render.md.handler.Context
---@field buf integer
---@field root TSNode

---@type table<string, render.md.Handler>
local builtin_handlers = {
    html = require('render-markdown.handler.html'),
    latex = require('render-markdown.handler.latex'),
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
}

---@class render.md.ui.Config
---@field on render.md.callback.Config
---@field custom_handlers table<string, render.md.Handler>

---@class render.md.Ui
---@field private config render.md.ui.Config
local M = {}

M.ns = vim.api.nvim_create_namespace('render-markdown.nvim')

---@private
---@type table<integer, render.md.Buffer>
M.cache = {}

---called from state on setup
---@param config render.md.ui.Config
function M.setup(config)
    M.config = config
    -- reset cache
    for buf, buffer in pairs(M.cache) do
        M.clear_buffer(buf, buffer)
    end
    M.cache = {}
end

---@param buf integer
---@return render.md.Buffer
function M.get(buf)
    local result = M.cache[buf]
    if not result then
        result = Buffer.new(buf)
        M.cache[buf] = result
    end
    return result
end

---Used directly by fzf-lua: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/previewer/builtin.lua
---@param buf integer
---@param win integer
---@param event string
---@param change boolean
function M.update(buf, win, event, change)
    log.buf('info', 'update', buf, event, ('change %s'):format(change))
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config = state.get(buf)
    local buffer = M.get(buf)
    if buffer:is_empty() then
        return
    end

    local update = log.runtime('update', function()
        M.run_update(buf, win, change)
    end)
    buffer:run(parse, config.debounce, update)
end

---@private
---@param buf integer
---@param win integer
---@param change boolean
function M.run_update(buf, win, change)
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config = state.get(buf)
    local buffer = M.get(buf)
    local mode = Env.mode.get()
    local row = Env.row.get(buf, win)

    local render = state.enabled
        and config.enabled
        and config:render(mode)
        and not Env.win.get(win, 'diff')
        and Env.win.view(win).leftcol == 0

    log.buf('info', 'render', buf, render)
    local next_state = render and 'rendered' or 'default'
    for _, window in ipairs(Env.buf.windows(buf)) do
        for name, value in pairs(config.win_options) do
            Env.win.set(window, name, value[next_state])
        end
    end

    if render then
        local initial = buffer:initial()
        if initial or parse then
            M.clear_buffer(buf, buffer)
            buffer:set_marks(M.parse_buffer({
                buf = buf,
                win = win,
                config = config,
                mode = mode,
            }))
        end
        local range = config:hidden(mode, row)
        local extmarks = buffer:get_marks()
        if initial then
            Compat.fix_lsp_window(buf, win, extmarks)
            M.config.on.initial({ buf = buf, win = win })
        end
        for _, extmark in ipairs(extmarks) do
            if extmark:get().conceal and extmark:overlaps(range) then
                extmark:hide(M.ns, buf)
            else
                extmark:show(M.ns, buf)
            end
        end
        M.config.on.render({ buf = buf, win = win })
    else
        M.clear_buffer(buf, buffer)
        M.config.on.clear({ buf = buf, win = win })
    end
end

---@private
---@param buf integer
---@param win integer
---@param change boolean
---@return boolean
function M.parse(buf, win, change)
    -- need to parse when things change or we have not parsed the visible range yet
    return change or not Context.contains(buf, win)
end

---@private
---@param buf integer
---@param buffer render.md.Buffer
function M.clear_buffer(buf, buffer)
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
    buffer:set_marks(nil)
end

---@private
---@param props render.md.context.Props
---@return render.md.Extmark[]
function M.parse_buffer(props)
    local buf = props.buf
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser or not parser then
        log.buf('error', 'fail', buf, 'no treesitter parser found')
        return {}
    end
    -- reset buffer context
    local context = Context.reset(props)
    -- make sure injections are processed
    context:parse(parser)
    -- parse markdown after other nodes to get accurate state
    local marks = {} ---@type render.md.Mark[]
    local markdown = {} ---@type render.md.handler.Context[]
    parser:for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        ---@type render.md.handler.Context
        local ctx = { buf = buf, root = tree:root() }
        if language == 'markdown' then
            markdown[#markdown + 1] = ctx
        else
            vim.list_extend(marks, M.parse_tree(context, ctx, language))
        end
    end)
    for _, ctx in ipairs(markdown) do
        vim.list_extend(marks, M.parse_tree(context, ctx, 'markdown'))
    end
    return Iter.list.map(marks, Extmark.new)
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param context render.md.Context
---@param ctx render.md.handler.Context
---@param language string
---@return render.md.Mark[]
function M.parse_tree(context, ctx, language)
    log.buf('debug', 'language', ctx.buf, language)
    if not context:overlaps(ctx.root) then
        return {}
    end

    local marks = {}
    local user = M.config.custom_handlers[language]
    if user then
        log.buf('debug', 'handler', ctx.buf, 'user')
        vim.list_extend(marks, user.parse(ctx))
        if not user.extends then
            return marks
        end
    end
    local builtin = builtin_handlers[language]
    if builtin then
        log.buf('debug', 'handler', ctx.buf, 'builtin')
        vim.list_extend(marks, builtin.parse(ctx))
    end
    return marks
end

return M
