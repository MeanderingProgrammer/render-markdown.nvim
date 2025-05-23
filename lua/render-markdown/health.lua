local Icons = require('render-markdown.lib.icons')
local state = require('render-markdown.state')

---@class render.md.Health
local M = {}

---@private
M.version = '8.4.5'

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
    local latex = config.latex
    local html = config.html

    M.start('treesitter')
    M.parser('markdown', true)
    M.highlights('markdown')
    M.highlighter('markdown')
    M.parser('markdown_inline', true)
    M.highlights('markdown_inline')
    if latex.enabled then
        M.parser('latex', false)
    end
    if html.enabled then
        M.parser('html', false)
    end

    M.start('icons')
    local provider = Icons.name()
    if provider then
        vim.health.ok('using: ' .. provider)
    else
        vim.health.warn('none installed')
    end

    M.start('executables')
    if latex.enabled then
        M.executable(latex.converter, M.disable('latex'))
    end

    M.start('conflicts')
    M.plugin('headlines')
    M.plugin('markview')
    M.plugin('obsidian', function(obsidian)
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
---@param required boolean
function M.parser(language, required)
    local ok = pcall(vim.treesitter.get_parser, 0, language)
    if ok then
        vim.health.ok(language .. ': parser installed')
    else
        local message = language .. ': parser not installed'
        if not required then
            vim.health.warn(message, M.disable(language))
        else
            vim.health.error(message)
        end
    end
end

---@private
---@param language string
function M.highlights(language)
    local files = vim.treesitter.query.get_files(language, 'highlights')
    if #files > 0 then
        for _, file in ipairs(files) do
            local path = vim.fn.fnamemodify(file, ':~')
            vim.health.ok(language .. ': highlights ' .. path)
        end
    else
        vim.health.error(language .. ': highlights missing')
    end
end

---@private
---@param language string
function M.highlighter(language)
    -- nvim-treesitter is removing module support so cannot be used to check
    -- if highlights are enabled, so we create a buffer and check the state
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = language
    local ok = vim.treesitter.highlighter.active[buf] ~= nil
    vim.api.nvim_buf_delete(buf, { force = true })
    if ok then
        vim.health.ok(language .. ': highlighter enabled')
    else
        -- TODO(1.0): update advice once module support is removed
        vim.health.error(language .. ': highlighter not enabled', {
            'enable the highlight module in your nvim-treesitter config',
            "require('nvim-treesitter.configs').setup({ highlight = { enable = true } })",
        })
    end
end

---@private
---@param name string
---@param advice? string[]
function M.executable(name, advice)
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ': installed')
    else
        local message = name .. ': not installed'
        if advice then
            vim.health.warn(message, advice)
        else
            vim.health.error(message)
        end
    end
end

---@private
---@param name string
---@param validate? fun(plugin: any): string[]?
function M.plugin(name, validate)
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

---@private
---@param language string
---@return string[]
function M.disable(language)
    local setup = "require('render-markdown').setup"
    return {
        ('disable %s support to avoid this warning'):format(language),
        ('%s({ %s = { enabled = false } })'):format(setup, language),
    }
end

return M
