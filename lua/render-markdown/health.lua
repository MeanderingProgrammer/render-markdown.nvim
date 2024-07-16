local state = require('render-markdown.state')

---@class render.md.Health
local M = {}

function M.check()
    vim.health.start('markdown.nvim [neovim version]')
    M.version('0.9', '0.10')

    vim.health.start('markdown.nvim [configuration]')
    local errors = state.validate()
    if #errors == 0 then
        vim.health.ok('valid')
    end
    for _, message in ipairs(errors) do
        vim.health.error(message)
    end

    local latex = state.config.latex
    local latex_advice = 'Disable LaTeX support to avoid this warning by setting { latex = { enabled = false } }'

    vim.health.start('markdown.nvim [nvim-treesitter]')
    local ok = pcall(require, 'nvim-treesitter')
    if ok then
        vim.health.ok('installed')

        M.check_parser('markdown')
        M.check_parser('markdown_inline')
        if latex.enabled then
            M.check_parser('latex', latex_advice)
        end

        local highlight = require('nvim-treesitter.configs').get_module('highlight')
        if highlight ~= nil and highlight.enable then
            vim.health.ok('highlights enabled')
        else
            vim.health.error('highlights not enabled')
        end
    else
        vim.health.error('not installed')
    end

    vim.health.start('markdown.nvim [executables]')
    if latex.enabled then
        M.check_executable(latex.converter, latex_advice)
    else
        vim.health.ok('none to check')
    end
end

---@param minimum string
---@param recommended string
function M.version(minimum, recommended)
    if vim.fn.has('nvim-' .. minimum) == 0 then
        vim.health.error('Version < ' .. minimum)
    elseif vim.fn.has('nvim-' .. recommended) == 0 then
        vim.health.warn('Version < ' .. recommended .. ' some features will not work')
    else
        vim.health.ok('Version >= ' .. recommended)
    end
end

---@param name string
---@param advice string?
function M.check_parser(name, advice)
    local parsers = require('nvim-treesitter.parsers')
    if parsers.has_parser(name) then
        vim.health.ok(name .. ': parser installed')
    elseif advice == nil then
        vim.health.error(name .. ': parser not installed')
    else
        vim.health.warn(name .. ': parser not installed', advice)
    end
end

---@param name string
---@param advice string?
function M.check_executable(name, advice)
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ': installed')
    elseif advice == nil then
        vim.health.error(name .. ': not installed')
    else
        vim.health.warn(name .. ': not installed', advice)
    end
end

return M
