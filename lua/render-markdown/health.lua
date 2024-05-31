local md = require('render-markdown')
local state = require('render-markdown.state')

local function validate_treesitter()
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

---@param t1 table<any, any>
---@param t2 table<any, any>
---@param path string[]
---@return string[]
local function check_keys(t1, t2, path)
    local errors = {}
    for k, v2 in pairs(t2) do
        local v1 = t1[k]
        local key_path = vim.list_extend(vim.list_extend({}, path), { k })
        local key = vim.fn.join(key_path, ' -> ')
        if v1 == nil then
            table.insert(errors, string.format('Invalid parameter: %s', key))
        elseif type(v1) ~= type(v2) then
            table.insert(errors, string.format('Invalid type: %s, expected %s but found %s', key, type(v1), type(v2)))
        elseif type(v1) == 'table' and type(v2) == 'table' then
            -- Some tables are meant to have unrestricted keys
            if not vim.list_contains({ 'win_options', 'custom_handlers' }, k) then
                vim.list_extend(errors, check_keys(v1, v2, key_path))
            end
        end
    end
    return errors
end

local M = {}

function M.check()
    vim.health.start('Validating treesitter parsers & settings')
    validate_treesitter()
    vim.health.start('Validating configuration')
    local errors = check_keys(md.default_config, state.config, {})
    if #errors == 0 then
        vim.health.ok('Configuration is valid')
    end
    for _, message in ipairs(errors) do
        vim.health.error(message)
    end
end

return M
