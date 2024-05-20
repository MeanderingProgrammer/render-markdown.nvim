local latex = require('render-markdown.handler.latex')
local logger = require('render-markdown.logger')
local markdown = require('render-markdown.handler.markdown')
local markdown_inline = require('render-markdown.handler.markdown_inline')
local state = require('render-markdown.state')
local util = require('render-markdown.util')

local M = {}

M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

---@param buf integer
M.refresh = function(buf)
    if not state.enabled then
        return
    end
    if not M.clear_valid(buf) then
        return
    end
    if not vim.tbl_contains(state.config.render_modes, vim.fn.mode()) then
        return
    end
    if util.file_size_mb(buf) > state.config.max_file_size then
        return
    end

    logger.start()
    util.set_conceal(buf, state.config.conceal.rendered)

    -- Make sure injections are processed
    vim.treesitter.get_parser(buf):parse(true)

    vim.treesitter.get_parser(buf):for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        logger.debug({ language = language })
        if language == 'markdown' then
            markdown.render(M.namespace, tree:root(), buf)
        elseif language == 'markdown_inline' then
            markdown_inline.render(M.namespace, tree:root(), buf)
        elseif language == 'latex' then
            latex.render(M.namespace, tree:root(), buf)
        else
            logger.debug('No handler found')
        end
    end)
    logger.flush()
end

--- Remove existing highlights / virtual text for valid buffers
---@param buf integer
---@return boolean
M.clear_valid = function(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    if util.buf_to_win(buf) < 0 then
        return false
    end
    if not vim.tbl_contains(state.config.file_types, vim.bo[buf].filetype) then
        return false
    end
    vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
    util.set_conceal(buf, state.config.conceal.default)
    return true
end

return M
