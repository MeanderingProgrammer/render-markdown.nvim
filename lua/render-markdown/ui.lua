local logger = require('render-markdown.logger')
local profiler = require('render-markdown.profiler')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    latex = require('render-markdown.handler.latex'),
}

---@class render.md.UiCache
local cache = {
    ---@type table<integer, render.md.Mark[]>
    marks = {},
}

---@class render.md.Ui
local M = {}

---@type integer
M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

function M.invalidate_cache()
    cache.marks = {}
end

---@param buf integer
---@param parse boolean
function M.schedule_render(buf, parse)
    local mode = vim.fn.mode(true)
    vim.schedule(function()
        if state.config.profile then
            profiler.profile(buf, function()
                return M.render(buf, mode, parse)
            end)
        else
            M.render(buf, mode, parse)
        end
    end)
end

---@private
---@param buf integer
---@param mode string
---@param parse boolean
---@return 'invalid'|'disable'|'parsed'|'movement'
function M.render(buf, mode, parse)
    -- Check that buffer and associated window are valid
    local win = util.buf_to_win(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
        return 'invalid'
    end
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)

    if not M.should_render(win, mode) then
        -- Set window options back to default
        for name, value in pairs(state.config.win_options) do
            util.set_win(win, name, value.default)
        end
        return 'disable'
    else
        -- Set window options to rendered & perform render
        for name, value in pairs(state.config.win_options) do
            util.set_win(win, name, value.rendered)
        end

        -- Re-compute marks, needed if missing or between text changes
        local marks = cache.marks[buf]
        local parsed = marks == nil or parse
        if parsed then
            logger.start()
            marks = M.parse_buffer(buf)
            logger.flush()
            cache.marks[buf] = marks
        end

        local row = util.cursor_row(buf)
        for _, mark in ipairs(marks) do
            if M.should_show_mark(mark, row) then
                -- Only ensure strictness if the buffer was parsed this request
                -- The order of events can cause our cache to be stale
                mark.opts.strict = parsed
                vim.api.nvim_buf_set_extmark(buf, M.namespace, mark.start_row, mark.start_col, mark.opts)
            end
        end

        if parsed then
            return 'parsed'
        else
            return 'movement'
        end
    end
end

---@private
---@param win integer
---@param mode string
---@return boolean
function M.should_render(win, mode)
    if not state.enabled then
        return false
    end
    if not util.get_leftcol(win) == 0 then
        return false
    end
    if not vim.tbl_contains(state.config.render_modes, mode) then
        return false
    end
    return true
end

---@private
---@param buf integer
---@return render.md.Mark[]
function M.parse_buffer(buf)
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser then
        return {}
    end
    -- Make sure injections are processed
    if not parser:is_valid() then
        parser:parse(true)
    end
    -- Parse marks
    local marks = {}
    parser:for_each_tree(function(tree, language_tree)
        vim.list_extend(marks, M.parse_tree(buf, language_tree:lang(), tree:root()))
    end)
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

    local marks = {}
    local user_handler = state.config.custom_handlers[language]
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

---Render marks based on anti-conceal behavior and current row
---@private
---@param mark render.md.Mark
---@param row? integer
---@return boolean
function M.should_show_mark(mark, row)
    -- Anti-conceal is not enabled -> all marks should be shown
    if not state.config.anti_conceal.enabled then
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

return M
