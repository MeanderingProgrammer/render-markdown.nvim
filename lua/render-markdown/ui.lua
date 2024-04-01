local latex = require('render-markdown.handler.latex')
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

    vim.opt_local.conceallevel = state.config.conceal.rendered
    vim.treesitter.get_parser():for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        if language == 'markdown' then
            markdown.render(M.namespace, tree:root())
        elseif language == 'markdown_inline' then
            markdown_inline.render(M.namespace, tree:root())
        elseif language == 'latex' then
            latex.render(M.namespace, tree:root())
        end
    end)
end

return M
