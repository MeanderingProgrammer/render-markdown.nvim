local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    latex = require('render-markdown.handler.latex'),
}

---@class render.md.UiCache
---@field marks table<integer, render.md.Mark[]>

---@type render.md.UiCache
local cache = {
    marks = {},
}

---@class render.md.Ui
local M = {}

---@type integer
M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

---@param buf integer
---@param parse boolean
M.schedule_refresh = function(buf, parse)
    local mode = vim.fn.mode(true)
    vim.schedule(function()
        logger.start()
        M.refresh(buf, mode, parse)
        logger.flush()
    end)
end

---@private
---@param buf integer
---@param mode string
---@param parse boolean
M.refresh = function(buf, mode, parse)
    -- Remove any existing marks if buffer is valid
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)

    -- Check that buffer is associated with a valid window before window operations
    local win = util.buf_to_win(buf)
    if not vim.api.nvim_win_is_valid(win) then
        return
    end

    if not M.should_render(buf, win, mode) then
        -- Set window options back to default
        for name, value in pairs(state.config.win_options) do
            util.set_win(win, name, value.default)
        end
        return
    end

    -- Set window options to rendered & perform render
    for name, value in pairs(state.config.win_options) do
        util.set_win(win, name, value.rendered)
    end

    -- Re-compute marks, needed if missing or between text changes
    local marks = cache.marks[buf]
    if marks == nil or parse then
        marks = {}
        -- Make sure injections are processed
        local parser = vim.treesitter.get_parser(buf)
        parser:parse(true)
        -- Parse and cache marks
        parser:for_each_tree(function(tree, language_tree)
            vim.list_extend(marks, M.parse(buf, language_tree:lang(), tree:root()))
        end)
        cache.marks[buf] = marks
    end

    -- Render marks based on anti-conceal behavior and current row
    local row = vim.api.nvim_win_get_cursor(util.buf_to_win(buf))[1] - 1
    for _, mark in ipairs(marks) do
        if not state.config.anti_conceal.enabled or not mark.conceal or mark.start_row ~= row then
            -- Only ensure strictness if the buffer was parsed this request
            -- The order of events can cause our cache to be stale
            mark.opts.strict = parse
            vim.api.nvim_buf_set_extmark(buf, M.namespace, mark.start_row, mark.start_col, mark.opts)
        end
    end
end

---@private
---@param buf integer
---@param win integer
---@param mode string
---@return boolean
M.should_render = function(buf, win, mode)
    if not state.enabled then
        return false
    end
    if not util.get_leftcol(win) == 0 then
        return false
    end
    if not vim.tbl_contains(state.config.render_modes, mode) then
        return false
    end
    if util.file_size_mb(buf) > state.config.max_file_size then
        return false
    end
    return true
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param buf integer
---@param language string
---@param root TSNode
---@return render.md.Mark[]
M.parse = function(buf, language, root)
    logger.debug('Language: ' .. language)

    local marks = {}
    local user_handler = state.config.custom_handlers[language]
    if user_handler ~= nil then
        logger.debug('Running user handler')
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
        logger.debug('Running builtin handler')
        vim.list_extend(marks, builtin_handler.parse(root, buf))
    end
    return marks
end

return M
