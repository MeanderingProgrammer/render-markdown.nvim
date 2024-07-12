local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    ---@diagnostic disable-next-line: assign-type-mismatch
    markdown = require('render-markdown.handler.markdown'),
    ---@diagnostic disable-next-line: assign-type-mismatch
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    ---@diagnostic disable-next-line: assign-type-mismatch
    latex = require('render-markdown.handler.latex'),
}

---@class render.md.Ui
local M = {}

---@type integer
M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

---@param buf integer
M.schedule_refresh = function(buf)
    local mode = vim.fn.mode(true)
    vim.schedule(function()
        logger.start()
        M.refresh(buf, mode)
        logger.flush()
    end)
end

---@private
---@param buf integer
---@param mode string
M.refresh = function(buf, mode)
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
            util.set_win_option(win, name, value.default)
        end
    else
        -- Set window options to rendered & perform render
        for name, value in pairs(state.config.win_options) do
            util.set_win_option(win, name, value.rendered)
        end
        -- Make sure injections are processed
        local parser = vim.treesitter.get_parser(buf)
        parser:parse(true)
        parser:for_each_tree(function(tree, language_tree)
            M.render(buf, language_tree:lang(), tree:root())
        end)
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
M.render = function(buf, language, root)
    logger.debug('Language: ' .. language)
    local user_handler = state.config.custom_handlers[language]
    if user_handler ~= nil then
        logger.debug('Running user handler')
        user_handler.render(M.namespace, root, buf)
        if not user_handler.extends then
            return
        end
    end
    local builtin_handler = builtin_handlers[language]
    if builtin_handler ~= nil then
        logger.debug('Running builtin handler')
        builtin_handler.render(M.namespace, root, buf)
    end
end

return M
