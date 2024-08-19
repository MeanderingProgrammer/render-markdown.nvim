local state = require('render-markdown.state')

---@class render.md.Health
local M = {}

---@private
---@type string
M.version = '6.1.8'

function M.check()
    vim.health.start('render-markdown.nvim [version]')
    vim.health.ok('plugin ' .. M.version)
    M.neovim('0.9', '0.10')

    vim.health.start('render-markdown.nvim [configuration]')
    local errors = state.validate()
    if #errors == 0 then
        vim.health.ok('valid')
    end
    for _, message in ipairs(errors) do
        vim.health.error(message)
    end

    local latex = state.latex
    local latex_advice = 'Disable LaTeX support to avoid this warning by setting { latex = { enabled = false } }'

    vim.health.start('render-markdown.nvim [nvim-treesitter]')
    local has_treesitter = pcall(require, 'nvim-treesitter')
    if has_treesitter then
        vim.health.ok('installed')
        for _, language in ipairs({ 'markdown', 'markdown_inline' }) do
            M.check_parser(language)
            M.check_highlight(language)
        end
        if latex.enabled then
            M.check_parser('latex', latex_advice)
        end
    else
        vim.health.error('not installed')
    end

    vim.health.start('render-markdown.nvim [executables]')
    if latex.enabled then
        M.check_executable(latex.converter, latex_advice)
    else
        vim.health.ok('none to check')
    end

    vim.health.start('render-markdown.nvim [conflicts]')
    if state.acknowledge_conflicts then
        vim.health.ok('conflicts acknowledged')
    else
        M.check_plugin('headlines')
        M.check_plugin('obsidian', {
            'Ensure UI is disabled by setting ui = { enable = false } in obsidian.nvim config',
            'Acknowledge conflicts to avoid this warning by setting { acknowledge_conflicts = true }',
        })
    end
end

---@private
---@param minimum string
---@param recommended string
function M.neovim(minimum, recommended)
    if vim.fn.has('nvim-' .. minimum) == 0 then
        vim.health.error('neovim < ' .. minimum)
    elseif vim.fn.has('nvim-' .. recommended) == 0 then
        vim.health.warn('neovim < ' .. recommended .. ' some features will not work')
    else
        vim.health.ok('neovim >= ' .. recommended)
    end
end

---@private
---@param language string
---@param advice? string
function M.check_parser(language, advice)
    local parsers = require('nvim-treesitter.parsers')
    if parsers.has_parser(language) then
        vim.health.ok(language .. ': parser installed')
    elseif advice == nil then
        vim.health.error(language .. ': parser not installed')
    else
        vim.health.warn(language .. ': parser not installed', advice)
    end
end

---@private
---@param language string
function M.check_highlight(language)
    local configs = require('nvim-treesitter.configs')
    if configs.is_enabled('highlight', language, 0) then
        vim.health.ok(language .. ': highlight enabled')
    else
        vim.health.error(language .. ': highlight not enabled')
    end
end

---@private
---@param name string
---@param advice? string
function M.check_executable(name, advice)
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ': installed')
    elseif advice == nil then
        vim.health.error(name .. ': not installed')
    else
        vim.health.warn(name .. ': not installed', advice)
    end
end

---@private
---@param name string
---@param advice? string[]
function M.check_plugin(name, advice)
    local has_plugin = pcall(require, name)
    if not has_plugin then
        vim.health.ok(name .. ': not installed')
    elseif advice == nil then
        vim.health.error(name .. ': installed')
    else
        vim.health.warn(name .. ': installed', advice)
    end
end

return M
