local md = require('render-markdown')
local state = require('render-markdown.state')

local M = {}

function M.check()
    local latex_advice = 'If you do not want LaTeX support avoid this warning by setting { latex_enabled = false }'

    vim.health.start('markdown.nvim [nvim-treesitter]')
    local ok = pcall(require, 'nvim-treesitter')
    if ok then
        vim.health.ok('installed')

        M.check_parser('markdown')
        M.check_parser('markdown_inline')
        if state.config.latex_enabled then
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
    if state.config.latex_enabled then
        M.check_executable(state.config.latex_converter, latex_advice)
    else
        vim.health.ok('none to check')
    end

    vim.health.start('markdown.nvim [configuration]')
    local errors = M.check_keys(md.default_config, state.config, {})
    if #errors == 0 then
        vim.health.ok('valid')
    end
    for _, message in ipairs(errors) do
        vim.health.error(message)
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

---@param t1 table<any, any>
---@param t2 table<any, any>
---@param path string[]
---@return string[]
function M.check_keys(t1, t2, path)
    local errors = {}
    for k, v2 in pairs(t2) do
        local v1 = t1[k]
        local key_path = vim.list_extend(vim.list_extend({}, path), { k })
        local key = vim.fn.join(key_path, '.')
        if v1 == nil then
            table.insert(errors, string.format('Invalid key: %s', key))
        elseif type(v1) ~= type(v2) then
            table.insert(errors, string.format('Invalid type: %s, expected %s, found %s', key, type(v1), type(v2)))
        elseif type(v1) == 'table' and type(v2) == 'table' then
            -- Some tables are meant to have unrestricted keys
            if not vim.list_contains({ 'win_options', 'custom_handlers' }, k) then
                vim.list_extend(errors, M.check_keys(v1, v2, key_path))
            end
        end
    end
    return errors
end

return M
