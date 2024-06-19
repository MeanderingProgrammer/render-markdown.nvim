local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

---@type table<string, render.md.Handler>
local builtin_handlers = {
    markdown = require('render-markdown.handler.markdown'),
    markdown_inline = require('render-markdown.handler.markdown_inline'),
    latex = require('render-markdown.handler.latex'),
}

---@class render.md.Ui
local M = {}

M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

---@param buf integer
M.schedule_refresh = function(buf)
    local mode = vim.fn.mode()
    vim.schedule(function()
        M.refresh(buf, mode)
    end)
end

---@param buf integer
M.schedule_clear = function(buf)
    vim.schedule(function()
        M.clear_valid(buf)
    end)
end

---@private
---@param buf integer
---@param mode string
M.refresh = function(buf, mode)
    if not state.enabled then
        return
    end
    if not M.clear_valid(buf) then
        return
    end
    if not vim.tbl_contains(state.config.render_modes, mode) then
        return
    end
    if util.file_size_mb(buf) > state.config.max_file_size then
        return
    end

    logger.start()
    for name, value in pairs(state.config.win_options) do
        util.set_win_option(buf, name, value.rendered)
    end
    -- Make sure injections are processed
    local parser = vim.treesitter.get_parser(buf)
    parser:parse(true)
    parser:for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        logger.debug('Language: ' .. language)
        local executed = M.render(buf, language, tree:root())
        logger.debug({ executed_handlers = executed })
    end)
    logger.flush()
end

---Run user & builtin handlers when available. User handler is always executed,
---builtin handler is skipped if user handler does not specify extends.
---@private
---@param buf integer
---@param language string
---@param root TSNode
---@return string[]
M.render = function(buf, language, root)
    local result = {}
    local user_handler = state.config.custom_handlers[language]
    if user_handler ~= nil then
        user_handler.render(M.namespace, root, buf)
        table.insert(result, 'user')
        if user_handler.extends ~= true then
            return result
        end
    end
    local builtin_handler = builtin_handlers[language]
    if builtin_handler ~= nil then
        builtin_handler.render(M.namespace, root, buf)
        table.insert(result, 'builtin')
    end
    return result
end

---Remove existing highlights / virtual text for valid buffers
---@private
---@param buf integer
---@return boolean
M.clear_valid = function(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    if not vim.tbl_contains(state.config.file_types, vim.bo[buf].filetype) then
        return false
    end
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
    local win = util.buf_to_win(buf)
    if not vim.api.nvim_win_is_valid(win) then
        return false
    end
    for name, value in pairs(state.config.win_options) do
        util.set_win_option(buf, name, value.default)
    end
    local leftcol = vim.api.nvim_win_call(win, function()
        return vim.fn.winsaveview().leftcol
    end)
    if leftcol > 0 then
        return false
    end
    return true
end

return M
