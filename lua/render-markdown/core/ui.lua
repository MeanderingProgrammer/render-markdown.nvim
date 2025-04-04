local Buffer = require('render-markdown.core.buffer')
local Compat = require('render-markdown.lib.compat')
local Context = require('render-markdown.core.context')
local Env = require('render-markdown.lib.env')
local Extmark = require('render-markdown.core.extmark')
local Iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    html = require('render-markdown.handler.html'),
    latex = require('render-markdown.handler.latex'),
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
}

---@class render.md.cache.Ui
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
---@param win integer
---@return integer, render.md.Mark[]
function M.get_row_marks(buf, win)
    local config, buffer = state.get(buf), Cache.get(buf)
    local mode, row = Env.mode.get(), Env.row.get(buf, win)
    local hidden = config:hidden(mode, row)
    assert(row ~= nil and hidden ~= nil, 'Row & range must be known to get marks')

    local marks = {}
    for _, extmark in ipairs(buffer:get_marks()) do
        if extmark:inside(hidden) then
            marks[#marks + 1] = extmark:get()
        end
    end
    return row, marks
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
    log.buf('info', 'update', buf, string.format('event %s', event), string.format('change %s', change))
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config, buffer = state.get(buf), Cache.get(buf)
    if buffer:is_empty() then
        return
    end

    local update = function()
        M.run_update(buf, win, change)
    end
    if parse and state.log_runtime then
        update = Env.runtime(update)
    end

    if parse and config.debounce > 0 then
        buffer:debounce(config.debounce, update)
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
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config, buffer = state.get(buf), Cache.get(buf)
    local mode, row = Env.mode.get(), Env.row.get(buf, win)
    local next_state = M.next_state(config, win, mode)

    log.buf('info', 'state', buf, next_state)
    for _, window in ipairs(Env.buf.windows(buf)) do
        for name, value in pairs(config.win_options) do
            Env.win.set(window, name, value[next_state])
        end
    end

    if next_state == 'rendered' then
        local initial = not buffer:has_marks()
        if initial or parse then
            M.clear(buf, buffer)
            buffer:set_marks(M.parse_buffer({
                buf = buf,
                win = win,
                mode = mode,
                top_level_mode = Env.mode.is(mode, config.render_modes),
            }))
        end
        local hidden = config:hidden(mode, row)
        local extmarks = buffer:get_marks()
        if initial then
            Compat.lsp_window_height(win, extmarks)
        end
        for _, extmark in ipairs(extmarks) do
            if extmark:get().conceal and extmark:inside(hidden) then
                extmark:hide(M.ns, buf)
            else
                extmark:show(M.ns, buf)
            end
        end
        state.on.render({ buf = buf })
    else
        M.clear(buf, buffer)
        state.on.clear({ buf = buf })
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
    if Env.win.get(win, 'diff') then
        return 'default'
    end
    if Env.win.view(win).leftcol ~= 0 then
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
            markdown_roots[#markdown_roots + 1] = tree:root()
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
