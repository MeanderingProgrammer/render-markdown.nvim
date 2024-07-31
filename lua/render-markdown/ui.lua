local context = require('render-markdown.context')
local extmark = require('render-markdown.extmark')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    latex = require('render-markdown.handler.latex'),
}

---@type table<integer, render.md.Extmark[]>
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

---@param buf integer
---@param parse boolean
function M.schedule_render(buf, parse)
    local mode = vim.fn.mode(true)
    vim.schedule(function()
        M.render(buf, mode, parse)
    end)
end

---@private
---@param buf integer
function M.clear(buf)
    for _, mark in ipairs(cache[buf] or {}) do
        mark:hide()
    end
end

---@private
---@param buf integer
---@param mode string
---@param parse boolean
function M.render(buf, mode, parse)
    -- Check that buffer and associated window are valid
    local win = util.buf_to_win(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
        return
    end

    local config = state.get_config(buf)
    if not M.should_render(config, win, mode) then
        M.clear(buf)
        -- Set window options back to default
        for name, value in pairs(config.win_options) do
            util.set_win(win, name, value.default)
        end
    else
        -- Set window options to rendered & perform render
        for name, value in pairs(config.win_options) do
            util.set_win(win, name, value.rendered)
        end

        -- Re-compute marks, needed if missing or between text changes
        local marks = cache[buf]
        if marks == nil or parse then
            M.clear(buf)
            logger.start()
            marks = M.parse_buffer(buf)
            logger.flush()
            cache[buf] = marks
        end

        local row = util.cursor_row(buf)
        for _, mark in ipairs(marks) do
            mark:render(row)
        end
    end
end

---@private
---@param config render.md.BufferConfig
---@param win integer
---@param mode string
---@return boolean
function M.should_render(config, win, mode)
    if not state.enabled then
        return false
    end
    if not util.get_leftcol(win) == 0 then
        return false
    end
    if not vim.tbl_contains(config.render_modes, mode) then
        return false
    end
    return true
end

---@private
---@param buf integer
---@return render.md.Extmark[]
function M.parse_buffer(buf)
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser then
        return {}
    end
    -- Make sure injections are processed
    if not parser:is_valid() then
        parser:parse(true)
    end
    -- Pre-compute conceal information after reseting buffer cache
    context.reset_buf(buf)
    context.compute_conceal(buf, parser)
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
    return vim.tbl_map(function(mark)
        return extmark.new(M.namespace, buf, mark)
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
    logger.debug('language', language)

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
