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

---@class render.md.ui.Cache
---@field states table<integer, render.md.Buffer>
local Cache = {
    states = {},
}

---@param buf integer
---@return render.md.Buffer
function Cache.get(buf)
    local buffer = Cache.states[buf]
    if buffer == nil then
        buffer = Buffer.new(buf)
        Cache.states[buf] = buffer
    end
    return buffer
end

---@class render.md.Ui
local M = {}

M.ns = vim.api.nvim_create_namespace('render-markdown.nvim')

function M.invalidate_cache()
    for buf, buffer in pairs(Cache.states) do
        M.clear(buf, buffer)
    end
    Cache.states = {}
end

---@param buf integer
---@param row integer
---@return render.md.Mark[]
function M.row_marks(buf, row)
    local config = state.get(buf)
    local buffer = Cache.get(buf)
    local mode = Env.mode.get()
    local hidden = assert(config:hidden(mode, row), 'range must be known')

    local marks = {}
    for _, extmark in ipairs(buffer:get_marks()) do
        if extmark:overlaps(hidden) then
            marks[#marks + 1] = extmark:get()
        end
    end
    return marks
end

---@private
---@param buf integer
---@param buffer render.md.Buffer
function M.clear(buf, buffer)
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
    buffer:set_marks(nil)
end

---Used directly by fzf-lua: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/previewer/builtin.lua
---@param buf integer
---@param win integer
---@param event string
---@param change boolean
function M.update(buf, win, event, change)
    log.buf('info', 'update', buf, event, string.format('change %s', change))
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config = state.get(buf)
    local buffer = Cache.get(buf)
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
    local buffer = Cache.get(buf)
    local mode = Env.mode.get()
    local row = Env.row.get(buf, win)
    local next_state = M.next_state(config, win, mode)

    log.buf('info', 'state', buf, next_state)
    for _, window in ipairs(Env.buf.windows(buf)) do
        for name, value in pairs(config.win_options) do
            Env.win.set(window, name, value[next_state])
        end
    end

    if next_state == 'rendered' then
        local initial = buffer:initial()
        if initial or parse then
            M.clear(buf, buffer)
            buffer:set_marks(M.parse_buffer({
                buf = buf,
                win = win,
                config = config,
                mode = mode,
            }))
        end
        local hidden = config:hidden(mode, row)
        local extmarks = buffer:get_marks()
        if initial then
            Compat.fix_lsp_window(buf, win, extmarks)
            state.on.initial({ buf = buf, win = win })
        end
        for _, extmark in ipairs(extmarks) do
            if extmark:get().conceal and extmark:overlaps(hidden) then
                extmark:hide(M.ns, buf)
            else
                extmark:show(M.ns, buf)
            end
        end
        state.on.render({ buf = buf, win = win })
    else
        M.clear(buf, buffer)
        state.on.clear({ buf = buf, win = win })
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
---@param config render.md.main.Config
---@param win integer
---@param mode string
---@return 'default'|'rendered'
function M.next_state(config, win, mode)
    local render = state.enabled
        and config.enabled
        and config:render(mode)
        and not Env.win.get(win, 'diff')
        and Env.win.view(win).leftcol == 0
    return render and 'rendered' or 'default'
end

---@private
---@param props render.md.context.Props
---@return render.md.Extmark[]
function M.parse_buffer(props)
    local buf = props.buf
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser or parser == nil then
        log.buf('error', 'fail', buf, 'no treesitter parser found')
        return {}
    end
    -- Reset buffer context
    Context.reset(props)
    -- Make sure injections are processed
    Context.get(buf):parse(parser)
    -- Parse markdown after all other nodes to take advantage of state
    local marks = {}
    local markdown_contexts = {}
    parser:for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        ---@type render.md.handler.Context
        local ctx = { buf = buf, root = tree:root() }
        if language == 'markdown' then
            markdown_contexts[#markdown_contexts + 1] = ctx
        else
            vim.list_extend(marks, M.parse_tree(ctx, language))
        end
    end)
    for _, ctx in ipairs(markdown_contexts) do
        vim.list_extend(marks, M.parse_tree(ctx, 'markdown'))
    end
    return Iter.list.map(marks, Extmark.new)
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param ctx render.md.handler.Context
---@param language string
---@return render.md.Mark[]
function M.parse_tree(ctx, language)
    log.buf('debug', 'language', ctx.buf, language)
    if not Context.get(ctx.buf):overlaps(ctx.root) then
        return {}
    end

    local marks = {}
    local user = state.custom_handlers[language]
    if user ~= nil then
        log.buf('debug', 'handler', ctx.buf, 'user')
        vim.list_extend(marks, user.parse(ctx))
        if not user.extends then
            return marks
        end
    end
    local builtin = builtin_handlers[language]
    if builtin ~= nil then
        log.buf('debug', 'handler', ctx.buf, 'builtin')
        vim.list_extend(marks, builtin.parse(ctx))
    end
    return marks
end

return M
