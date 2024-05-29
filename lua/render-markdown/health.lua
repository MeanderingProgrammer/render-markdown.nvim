local M = {}

function M.check()
    vim.health.start('Checking required treesitter parsers & settings')
    local ok, ts = pcall(require, 'nvim-treesitter.parsers')
    if not ok then
        vim.health.error('treesitter is not installed')
        return
    end
    vim.health.ok('treesitter is installed')

    for _, name in ipairs({ 'markdown', 'markdown_inline' }) do
        if ts.has_parser(name) then
            vim.health.ok(name .. ' parser installed')
        else
            vim.health.error(name .. ' parser not installed')
        end
    end

    local highlight = require('nvim-treesitter.configs').get_module('highlight')
    if highlight.enable then
        vim.health.ok('treesitter highlights enabled')
    else
        vim.health.error('treesitter highlights not enabled')
    end
end

return M
