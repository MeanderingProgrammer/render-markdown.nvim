local BufferState = require('render-markdown.core.buffer_state')
local Context = require('render-markdown.core.context')
local Extmark = require('render-markdown.core.extmark')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    latex = require('render-markdown.handler.latex'),
}

---@type table<integer, render.md.BufferState>
local cache = {}

---@class render.md.Ui
local M = {}

M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

function M.invalidate_cache()
    for buf, buffer_state in pairs(cache) do
        M.clear(buf, buffer_state)
    end
    cache = {}
end

---@param buf integer
---@return integer, render.md.Mark[]
function M.get_row_marks(buf)
    local buffer_state, row = cache[buf], util.cursor_row(buf)
    if buffer_state == nil or row == nil then
        return 0, {}
    end
    local marks = {}
    for _, extmark in ipairs(buffer_state.marks or {}) do
        if extmark:overlaps(row) then
            table.insert(marks, extmark.mark)
        end
    end
    return row, marks
end

---@private
---@param buf integer
---@param buffer_state render.md.BufferState
function M.clear(buf, buffer_state)
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
    buffer_state.marks = nil
end

---@param buf integer
---@param win integer
---@param event string
---@param change boolean
function M.debounce_update(buf, win, event, change)
    log.debug_buf('update', buf, string.format('event %s', event), string.format('change %s', change))
    if not util.valid(buf, win) then
        return
    end

    local config = state.get_config(buf)
    local buffer_state = cache[buf] or BufferState.new(buf)
    cache[buf] = buffer_state

    if not change and Context.contains_range(buf, win) then
        vim.schedule(function()
            M.update(buf, win, false)
        end)
    else
        buffer_state:debounce(config.debounce, function()
            M.update(buf, win, true)
        end)
    end
end

---@private
---@param buf integer
---@param win integer
---@param parse boolean
function M.update(buf, win, parse)
    if not util.valid(buf, win) then
        return
    end

    local config = state.get_config(buf)
    local buffer_state = cache[buf]

    local next_state = M.next_state(config, win)
    if next_state ~= buffer_state.state then
        for name, value in pairs(config.win_options) do
            util.set_win(win, name, value[next_state])
        end
    end
    buffer_state.state = next_state

    if next_state == 'rendered' then
        if buffer_state.marks == nil or parse then
            M.clear(buf, buffer_state)
            buffer_state.marks = M.parse_buffer(buf, win)
        end
        local row = util.cursor_row(buf, win)
        for _, mark in ipairs(buffer_state.marks) do
            mark:render(config, row)
        end
    else
        M.clear(buf, buffer_state)
    end
end

---@private
---@param config render.md.buffer.Config
---@param win integer
---@return 'default'|'rendered'
function M.next_state(config, win)
    if not state.enabled then
        return 'default'
    end
    if util.get_win(win, 'diff') then
        return 'default'
    end
    if not util.view(win).leftcol == 0 then
        return 'default'
    end
    if not config:render(vim.fn.mode(true)) then
        return 'default'
    end
    return 'rendered'
end

---@private
---@param buf integer
---@param win integer
---@return render.md.Extmark[]
function M.parse_buffer(buf, win)
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser then
        log.error_buf('fail', buf, 'no treesitter parser found')
        return {}
    end
    -- Reset buffer context
    Context.reset(buf, win)
    -- Make sure injections are processed
    parser:parse(Context.get(buf):range())
    -- Parse markdown after all other nodes to take advantage of state
    local marks, markdown_roots = {}, {}
    parser:for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        if language == 'markdown' then
            table.insert(markdown_roots, tree:root())
        else
            vim.list_extend(marks, M.parse_tree(buf, language, tree:root()))
        end
    end)
    for _, root in ipairs(markdown_roots) do
        vim.list_extend(marks, M.parse_tree(buf, 'markdown', root))
    end
    return vim.tbl_map(function(mark)
        return Extmark.new(M.namespace, buf, mark)
    end, marks)
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param buf integer
---@param language string
---@param root TSNode
---@return render.md.Mark[]
function M.parse_tree(buf, language, root)
    log.debug_buf('language', buf, language)
    if not Context.get(buf):contains_node(root) then
        return {}
    end

    local marks = {}
    local user = state.custom_handlers[language]
    if user ~= nil then
        log.debug_buf('running handler', buf, 'user')
        vim.list_extend(marks, user.parse(root, buf))
        if not user.extends then
            return marks
        end
    end
    local builtin = builtin_handlers[language]
    if builtin ~= nil then
        log.debug_buf('running handler', buf, 'builtin')
        vim.list_extend(marks, builtin.parse(root, buf))
    end
    return marks
end

return M
