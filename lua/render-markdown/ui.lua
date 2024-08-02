local buffer_state = require('render-markdown.buffer_state')
local context = require('render-markdown.context')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

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

---@type integer
M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

function M.invalidate_cache()
    for buf in pairs(cache) do
        M.clear(buf)
    end
    cache = {}
end

---@private
---@param buf integer
function M.clear(buf)
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
end

---@param buf integer
function M.debcoune_update(buf)
    local buf_state = cache[buf] or buffer_state.new(buf)
    cache[buf] = buf_state
    buf_state:debounce(state.get_config(buf).debounce, M.update)
end

---@private
---@param buf integer
function M.update(buf)
    -- Check that buffer and associated window are valid
    local win = util.buf_to_win(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
        return
    end

    local buf_state = cache[buf]
    local config = state.get_config(buf)

    local next_state = M.get_next_state(config, win)
    if next_state ~= buf_state.state then
        for name, value in pairs(config.win_options) do
            util.set_win(win, name, value[next_state])
        end
    end
    buf_state.state = next_state

    M.clear(buf)
    if next_state == 'rendered' then
        logger.start()
        local marks = M.parse_buffer(buf, win)
        logger.flush()
        local row = util.cursor_row(buf, win)
        for _, mark in ipairs(marks) do
            if M.should_show_mark(config, mark, row) then
                vim.api.nvim_buf_set_extmark(buf, M.namespace, mark.start_row, mark.start_col, mark.opts)
            end
        end
    end
end

---@private
---@param config render.md.BufferConfig
---@param win integer
---@return 'default'|'rendered'
function M.get_next_state(config, win)
    if not state.enabled then
        return 'default'
    end
    if not util.get_leftcol(win) == 0 then
        return 'default'
    end
    if not vim.tbl_contains(config.render_modes, vim.fn.mode(true)) then
        return 'default'
    end
    return 'rendered'
end

---Render marks based on anti-conceal behavior and current row
---@private
---@param config render.md.BufferConfig
---@param mark render.md.Mark
---@param row? integer
---@return boolean
function M.should_show_mark(config, mark, row)
    -- Anti-conceal is not enabled -> all marks should be shown
    if not config.anti_conceal.enabled then
        return true
    end
    -- Row is not known means buffer is not active -> all marks should be shown
    if row == nil then
        return true
    end
    -- Mark is not concealable -> mark should always be shown
    if not mark.conceal then
        return true
    end
    -- Show mark if it is not on the current row
    return mark.start_row ~= row
end

---@private
---@param buf integer
---@param win integer
---@return render.md.Mark[]
function M.parse_buffer(buf, win)
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser then
        return {}
    end
    -- Reset buffer context
    context.reset(buf, win)
    -- Make sure injections are processed
    parser:parse(context.get(buf):range())
    -- Parse marks
    local marks = {}
    -- Parse markdown after all other nodes to take advantage of state
    local markdown_roots = {}
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
    return marks
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param buf integer
---@param language string
---@param root TSNode
---@return render.md.Mark[]
function M.parse_tree(buf, language, root)
    logger.debug('language', language)
    if not context.get(buf):contains_node(root) then
        return {}
    end

    local marks = {}
    local user_handler = state.custom_handlers[language]
    if user_handler ~= nil then
        logger.debug('running handler', 'user')
        -- TODO: remove call to render & parse nil check
        ---@diagnostic disable-next-line: undefined-field
        if user_handler.render ~= nil then
            local message = 'markdown.nvim: custom_handlers render is deprecated use parse instead'
            message = message .. ', will be fully removed on 2024-08-19'
            vim.notify_once(message, vim.log.levels.ERROR)
            ---@diagnostic disable-next-line: undefined-field
            user_handler.render(M.namespace, root, buf)
        end
        if user_handler.parse ~= nil then
            vim.list_extend(marks, user_handler.parse(root, buf))
        end
        if not user_handler.extends then
            return marks
        end
    end
    local builtin_handler = builtin_handlers[language]
    if builtin_handler ~= nil then
        logger.debug('running handler', 'builtin')
        vim.list_extend(marks, builtin_handler.parse(root, buf))
    end
    return marks
end

return M
