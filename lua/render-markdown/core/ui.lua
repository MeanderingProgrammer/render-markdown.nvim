local BufferState = require('render-markdown.core.buffer_state')
local Context = require('render-markdown.core.context')
local Extmark = require('render-markdown.core.extmark')
local Iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    html = require('render-markdown.handler.html'),
    latex = require('render-markdown.handler.latex'),
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
}

---@class render.md.cache.Ui
---@field states table<integer, render.md.BufferState>
local Cache = {
    states = {},
}

---@param buf integer
---@return render.md.BufferState
function Cache.get(buf)
    local buffer_state = Cache.states[buf]
    if buffer_state == nil then
        buffer_state = BufferState.new()
        Cache.states[buf] = buffer_state
    end
    return buffer_state
end

---@class render.md.Ui
local M = {}

M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

function M.invalidate_cache()
    for buf, buffer_state in pairs(Cache.states) do
        M.clear(buf, buffer_state)
    end
    Cache.states = {}
end

---@param buf integer
---@param win integer
---@return integer, render.md.Mark[]
function M.get_row_marks(buf, win)
    local config, buffer_state = state.get(buf), Cache.get(buf)
    local mode, row = util.mode(), util.row(buf, win)
    local hidden = config:hidden(mode, row)
    assert(row ~= nil and hidden ~= nil, 'Row & range must be known to get marks')

    local marks = {}
    for _, extmark in ipairs(buffer_state:get_marks()) do
        local mark = extmark:get_mark()
        if hidden:contains(mark.start_row, mark.start_row) then
            table.insert(marks, mark)
        end
    end
    return row, marks
end

---@private
---@param buf integer
---@param buffer_state render.md.BufferState
function M.clear(buf, buffer_state)
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
    buffer_state:set_marks(nil)
end

---Used directly by fzf-lua: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/previewer/builtin.lua
---@param buf integer
---@param win integer
---@param event string
---@param change boolean
function M.update(buf, win, event, change)
    log.buf('info', 'update', buf, string.format('event %s', event), string.format('change %s', change))
    if not util.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config, buffer_state = state.get(buf), Cache.get(buf)

    local update = function()
        M.run_update(buf, win, change)
    end
    if parse and state.log_runtime then
        update = util.wrap_runtime(update)
    end

    if parse and config.debounce > 0 then
        buffer_state:debounce(config.debounce, update)
    else
        vim.schedule(update)
    end
end

---@private
---@param buf integer
---@param win integer
---@param change boolean
---@return boolean
function M.parse(buf, win, change)
    -- Need to parse when things change or we have not parsed the visible range yet
    return change or not Context.contains_range(buf, win)
end

---@private
---@param buf integer
---@param win integer
---@param change boolean
function M.run_update(buf, win, change)
    if not util.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config, buffer_state = state.get(buf), Cache.get(buf)
    local mode, row = util.mode(), util.row(buf, win)
    local next_state = M.next_state(config, win, mode)

    log.buf('info', 'state', buf, next_state)
    for _, window in ipairs(util.windows(buf)) do
        for name, value in pairs(config.win_options) do
            util.set('win', window, name, value[next_state])
        end
    end

    if next_state == 'rendered' then
        if not buffer_state:has_marks() or parse then
            M.clear(buf, buffer_state)
            buffer_state:set_marks(M.parse_buffer({
                buf = buf,
                win = win,
                mode = mode,
                top_level_mode = util.in_modes(config.render_modes, mode),
            }))
        end
        local hidden = config:hidden(mode, row)
        local extmarks = buffer_state:get_marks()
        for _, extmark in ipairs(extmarks) do
            local mark = extmark:get_mark()
            if mark.conceal and hidden ~= nil and hidden:contains(mark.start_row, mark.start_row) then
                extmark:hide(M.namespace, buf)
            else
                extmark:show(M.namespace, buf)
            end
        end
        state.on.render({ buf = buf })
    else
        M.clear(buf, buffer_state)
    end
end

---@private
---@param config render.md.buffer.Config
---@param win integer
---@param mode string
---@return 'default'|'rendered'
function M.next_state(config, win, mode)
    if not state.enabled then
        return 'default'
    end
    if not config.enabled then
        return 'default'
    end
    if not config:render(mode) then
        return 'default'
    end
    if util.get('win', win, 'diff') then
        return 'default'
    end
    if util.view(win).leftcol ~= 0 then
        return 'default'
    end
    return 'rendered'
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
    local marks, markdown_roots = {}, {}
    parser:for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        if language == 'markdown' then
            table.insert(markdown_roots, tree:root())
        else
            vim.list_extend(marks, M.parse_tree({ buf = buf, root = tree:root() }, language))
        end
    end)
    for _, root in ipairs(markdown_roots) do
        vim.list_extend(marks, M.parse_tree({ buf = buf, root = root }, 'markdown'))
    end
    return Iter.list.map(marks, Extmark.new)
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param ctx render.md.HandlerContext
---@param language string
---@return render.md.Mark[]
function M.parse_tree(ctx, language)
    log.buf('debug', 'language', ctx.buf, language)
    if not Context.get(ctx.buf):overlaps_node(ctx.root) then
        return {}
    end

    local marks = {}
    local user = state.custom_handlers[language]
    if user ~= nil then
        log.buf('debug', 'running handler', ctx.buf, 'user')
        vim.list_extend(marks, user.parse(ctx))
        if not user.extends then
            return marks
        end
    end
    local builtin = builtin_handlers[language]
    if builtin ~= nil then
        log.buf('debug', 'running handler', ctx.buf, 'builtin')
        vim.list_extend(marks, builtin.parse(ctx))
    end
    return marks
end

return M
