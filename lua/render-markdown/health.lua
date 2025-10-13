local env = require('render-markdown.lib.env')
local icons = require('render-markdown.lib.icons')
local state = require('render-markdown.state')

---@class render.md.Health
local M = {}

---@private
M.version = '8.9.6'

function M.check()
    M.start('versions')
    M.neovim('0.9', '0.11')
    vim.health.ok('tree-sitter ABI: ' .. vim.treesitter.language_version)
    vim.health.ok('plugin: ' .. M.version)

    M.start('configuration')
    local errors = state.validate()
    if #errors == 0 then
        vim.health.ok('valid')
    else
        for _, message in ipairs(errors) do
            vim.health.error(message)
        end
    end

    local config = state.get(0)
    local html = config.html
    local latex = config.latex
    local yaml = config.yaml

    M.ts_info('markdown', true, true)
    M.ts_info('markdown_inline', true, false)
    if html.enabled then
        M.ts_info('html', false, false)
    end
    if latex.enabled then
        M.ts_info('latex', false, false)
    end
    if yaml.enabled then
        M.ts_info('yaml', false, false)
    end

    M.start('icons')
    local provider = icons.name()
    if provider then
        vim.health.ok('using: ' .. provider)
    else
        vim.health.warn('none installed')
    end

    if latex.enabled then
        M.start('latex')
        local cmd = env.command(latex.converter)
        if cmd then
            vim.health.ok('using: ' .. cmd)
        else
            local message = 'none installed: ' .. vim.inspect(latex.converter)
            vim.health.warn(message, M.disable('latex'))
        end
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
---@param active boolean
function M.ts_info(language, required, active)
    M.start('tree-sitter ' .. language)

    local has_parser, parser = pcall(vim.treesitter.get_parser, 0, language)
    if has_parser and parser then
        vim.health.ok('parser: installed')
    else
        local message = 'parser: not installed'
        if not required then
            vim.health.warn(message, M.disable(language))
        else
            vim.health.error(message)
        end
    end

    local has_info, info = pcall(vim.treesitter.language.inspect, language)
    if has_info and info then
        vim.health.ok('ABI: ' .. info.abi_version)
    else
        local message = 'ABI: unknown'
        if not required then
            vim.health.warn(message, M.disable(language))
        else
            vim.health.error(message)
        end
    end

    if required then
        local files = vim.treesitter.query.get_files(language, 'highlights')
        if #files > 0 then
            for _, file in ipairs(files) do
                local path = vim.fn.fnamemodify(file, ':~')
                vim.health.ok('highlights: ' .. path)
            end
        else
            vim.health.error('highlights: unknown')
        end
    end

    if active then
        -- create a temporary buffer to check if vim.treesitter.start gets called
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].filetype = language
        local ok = vim.treesitter.highlighter.active[buf] ~= nil
        vim.api.nvim_buf_delete(buf, { force = true })
        if ok then
            vim.health.ok('highlighter: enabled')
        else
            vim.health.error('highlighter: not enabled', {
                ('call vim.treesitter.start on %s buffers'):format(language),
            })
        end
    end
end

---@private
---@param name string
---@param validate? fun(plugin: any): string[]?
function M.plugin(name, validate)
    local has_plugin, plugin = pcall(require, name) ---@type boolean, any
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
