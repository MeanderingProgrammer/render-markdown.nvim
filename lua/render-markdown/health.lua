local Icons = require('render-markdown.lib.icons')
local state = require('render-markdown.state')

---@class render.md.Health
local M = {}

---@private
M.version = '8.4.1'

function M.check()
    M.start('version')
    vim.health.ok('plugin ' .. M.version)
    M.neovim('0.9', '0.11')

    M.start('configuration')
    local errors = state.validate()
    if #errors == 0 then
        vim.health.ok('valid')
    end
    for _, message in ipairs(errors) do
        vim.health.error(message)
    end

    local config = state.get(0)
    local latex, latex_advice = config.latex, M.disable_advice('latex')
    local html, html_advice = config.html, M.disable_advice('html')

    M.start('treesitter')
    M.check_parser('markdown', true)
    M.check_parser('markdown_inline', true)
    M.check_parser('latex', latex.enabled, latex_advice)
    M.check_parser('html', html.enabled, html_advice)
    M.check_highlight('markdown')

    M.start('icons')
    local provider = Icons.name()
    if provider then
        vim.health.ok('using: ' .. provider)
    else
        vim.health.warn('none installed')
    end

    M.start('executables')
    M.check_executable(latex.converter, latex.enabled, latex_advice)

    M.start('conflicts')
    M.check_plugin('headlines')
    M.check_plugin('markview')
    M.check_plugin('obsidian', function(obsidian)
        if obsidian.get_client().opts.ui.enable == false then
            return nil
        else
            return {
                'Disable the UI in your obsidian.nvim config',
                "require('obsidian').setup({ ui = { enable = false } })",
            }
        end
    end)
end

---@private
---@param name string
function M.start(name)
    vim.health.start(('render-markdown.nvim [%s]'):format(name))
end

---@private
---@param min string
---@param rec string
function M.neovim(min, rec)
    if vim.fn.has('nvim-' .. min) == 0 then
        vim.health.error('neovim < ' .. min)
    elseif vim.fn.has('nvim-' .. rec) == 0 then
        vim.health.warn('neovim < ' .. rec .. ' some features will not work')
    else
        vim.health.ok('neovim >= ' .. rec)
    end
end

---@private
---@param language string
---@return string[]
function M.disable_advice(language)
    local setup = "require('render-markdown').setup"
    return {
        ('disable %s support to avoid this warning'):format(language),
        ('%s({ %s = { enabled = false } })'):format(setup, language),
    }
end

---@private
---@param language string
---@param required boolean
---@param advice? string[]
function M.check_parser(language, required, advice)
    local has_parser = pcall(vim.treesitter.get_parser, 0, language)
    if has_parser then
        vim.health.ok(language .. ': parser installed')
    else
        local message = language .. ': parser not installed'
        if not required then
            vim.health.ok(message)
        elseif advice then
            vim.health.warn(message, advice)
        else
            vim.health.error(message)
        end
    end
end

---@private
---@param filetype string
function M.check_highlight(filetype)
    -- As nvim-treesitter is removing module support it cannot be used to check
    -- if highlights are enabled, so we create a buffer and check the state
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].filetype = filetype
    local has_highlighter = vim.treesitter.highlighter.active[bufnr] ~= nil
    vim.api.nvim_buf_delete(bufnr, { force = true })
    if has_highlighter then
        vim.health.ok(filetype .. ': highlight enabled')
    else
        -- TODO(1.0): update advice once module support is removed
        vim.health.error(filetype .. ': highlight not enabled', {
            'Enable the highlight module in your nvim-treesitter config',
            "require('nvim-treesitter.configs').setup({ highlight = { enable = true } })",
        })
    end
end

---@private
---@param name string
---@param required boolean
---@param advice? string[]
function M.check_executable(name, required, advice)
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ': installed')
    else
        local message = name .. ': not installed'
        if not required then
            vim.health.ok(message)
        elseif advice then
            vim.health.warn(message, advice)
        else
            vim.health.error(message)
        end
    end
end

---@private
---@param name string
---@param validate? fun(plugin: any): string[]?
function M.check_plugin(name, validate)
    local has_plugin, plugin = pcall(require, name)
    if not has_plugin then
        vim.health.ok(name .. ': not installed')
    elseif not validate then
        vim.health.error(name .. ': installed')
    else
        local advice = validate(plugin)
        if advice then
            vim.health.error(name .. ': installed', advice)
        else
            vim.health.ok(name .. ': installed but should not conflict')
        end
    end
end

return M
