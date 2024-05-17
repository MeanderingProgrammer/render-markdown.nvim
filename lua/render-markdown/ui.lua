local latex = require('render-markdown.handler.latex')
local logger = require('render-markdown.logger')
local markdown = require('render-markdown.handler.markdown')
local markdown_inline = require('render-markdown.handler.markdown_inline')
local state = require('render-markdown.state')

local M = {}

M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

M.clear = function()
    -- Remove existing highlights / virtual text
    vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)
    vim.opt_local.conceallevel = state.config.conceal.default
end

M.refresh = function()
    if not state.enabled then
        return
    end
    if not vim.tbl_contains(state.config.file_types, vim.bo.filetype) then
        return
    end
    -- Needs to happen after file_type check and before mode check
    M.clear()
    if not vim.tbl_contains(state.config.render_modes, vim.fn.mode()) then
        return
    end
    if M.file_size_mb() > state.config.max_file_size then
        return
    end

    logger.start()
    vim.opt_local.conceallevel = state.config.conceal.rendered

    -- Make sure injections are processed
    vim.treesitter.get_parser():parse(true)

    vim.treesitter.get_parser():for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        logger.debug({ language = language })
        if language == 'markdown' then
            markdown.render(M.namespace, tree:root())
        elseif language == 'markdown_inline' then
            markdown_inline.render(M.namespace, tree:root())
        elseif language == 'latex' then
            latex.render(M.namespace, tree:root())
        else
            logger.debug('No handler found')
        end
    end)
    logger.flush()
end

---@return number
M.file_size_mb = function()
    local ok, stats = pcall(function()
        return vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
    end)
    if not (ok and stats) then
        return 0
    end
    return stats.size / (1024 * 1024)
end

return M
