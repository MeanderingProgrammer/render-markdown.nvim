local state = require('render-markdown.state')

---@class render.md.Health
local M = {}

---@private
M.version = '7.7.4'

function M.check()
    M.start('version')
    vim.health.ok('plugin ' .. M.version)
    M.neovim('0.9', '0.10')

    M.start('configuration')
    local errors = state.validate()
    if #errors == 0 then
        vim.health.ok('valid')
    end
    for _, message in ipairs(errors) do
        vim.health.error(message)
    end

    local latex = state.latex
    local latex_advice = 'Disable LaTeX support to avoid this warning by setting { latex = { enabled = false } }'

    M.start('nvim-treesitter')
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

    M.start('executables')
    if latex.enabled then
        M.check_executable(latex.converter, latex_advice)
    else
        vim.health.ok('none to check')
    end

    M.start('conflicts')
    M.check_plugin('headlines')
    M.check_plugin('obsidian', function(obsidian)
        if obsidian.get_client().opts.ui.enable == false then
            return nil
        else
            return 'Ensure UI is disabled by setting ui = { enable = false } in obsidian.nvim config'
        end
    end)
end

---@private
---@param name string
function M.start(name)
    vim.health.start(string.format('render-markdown.nvim [%s]', name))
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
---@param validate? fun(plugin: any): string?
function M.check_plugin(name, validate)
    local has_plugin, plugin = pcall(require, name)
    if not has_plugin then
        vim.health.ok(name .. ': not installed')
    elseif validate == nil then
        vim.health.error(name .. ': installed')
    else
        local advice = validate(plugin)
        if advice == nil then
            vim.health.ok(name .. ': installed but should not conflict')
        else
            vim.health.error(name .. ': installed', advice)
        end
    end
end

return M
