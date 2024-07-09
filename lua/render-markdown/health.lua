local state = require('render-markdown.state')

local M = {}

function M.check()
    local latex_advice = 'Disable LaTeX support to avoid this warning by setting { latex = { enabled = false } }'

    vim.health.start('markdown.nvim [nvim-treesitter]')
    local ok = pcall(require, 'nvim-treesitter')
    if ok then
        vim.health.ok('installed')

        M.check_parser('markdown')
        M.check_parser('markdown_inline')
        if state.config.latex.enabled then
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
    if state.config.latex.enabled then
        M.check_executable(state.config.latex.converter, latex_advice)
    else
        vim.health.ok('none to check')
    end

    vim.health.start('markdown.nvim [configuration]')
    local errors = M.check_config(state.config)
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

---@param config render.md.Config
---@return string[]
function M.check_config(config)
    local errors = {}

    ---@param value string
    ---@param valid_values string[]
    ---@return vim.validate.Spec
    local function one_of(value, valid_values)
        return {
            value,
            function(v)
                return vim.tbl_contains(valid_values, v)
            end,
            'one of ' .. vim.inspect(valid_values),
        }
    end

    ---@param path string?
    ---@param opts table<string, vim.validate.Spec>
    local function append_errors(path, opts)
        local ok, err = pcall(vim.validate, opts)
        if not ok then
            if path == nil then
                table.insert(errors, err)
            else
                table.insert(errors, path .. '.' .. err)
            end
        end
    end

    ---@param path string
    ---@param values string[]
    local function all_strings(path, values)
        for i, value in ipairs(values) do
            append_errors(path, {
                [tostring(i)] = { value, 'string' },
            })
        end
    end

    append_errors(nil, {
        enabled = { config.enabled, 'boolean' },
        max_file_size = { config.max_file_size, 'number' },
        markdown_query = { config.markdown_query, 'string' },
        markdown_quote_query = { config.markdown_quote_query, 'string' },
        inline_query = { config.inline_query, 'string' },
        log_level = one_of(config.log_level, { 'debug', 'error' }),
        file_types = { config.file_types, 'table' },
        render_modes = { config.render_modes, 'table' },
        latex = { config.latex, 'table' },
        heading = { config.heading, 'table' },
        code = { config.code, 'table' },
        dash = { config.dash, 'table' },
        bullet = { config.bullet, 'table' },
        pipe_table = { config.pipe_table, 'table' },
        checkbox = { config.checkbox, 'table' },
        quote = { config.quote, 'table' },
        callout = { config.callout, 'table' },
        win_options = { config.win_options, 'table' },
        custom_handlers = { config.custom_handlers, 'table' },
    })

    all_strings('file_types', config.file_types)
    all_strings('render_modes', config.render_modes)

    local latex = config.latex
    append_errors('latex', {
        enabled = { latex.enabled, 'boolean' },
        converter = { latex.converter, 'string' },
        highlight = { latex.highlight, 'string' },
    })

    local heading = config.heading
    append_errors('heading', {
        icons = { heading.icons, 'table' },
        backgrounds = { heading.backgrounds, 'table' },
        foregrounds = { heading.foregrounds, 'table' },
    })
    all_strings('heading.icons', heading.icons)
    all_strings('heading.backgrounds', heading.backgrounds)
    all_strings('heading.foregrounds', heading.foregrounds)

    local code = config.code
    append_errors('code', {
        style = one_of(code.style, { 'full', 'language', 'normal', 'none' }),
        highlight = { code.highlight, 'string' },
    })

    local dash = config.dash
    append_errors('dash', {
        icon = { dash.icon, 'string' },
        highlight = { dash.highlight, 'string' },
    })

    local bullet = config.bullet
    append_errors('bullet', {
        icons = { bullet.icons, 'table' },
        highlight = { bullet.highlight, 'string' },
    })
    all_strings('bullet.icons', bullet.icons)

    local checkbox = config.checkbox
    append_errors('checkbox', {
        unchecked = { checkbox.unchecked, 'table' },
        checked = { checkbox.checked, 'table' },
        custom = { checkbox.custom, 'table' },
    })
    local unchecked = checkbox.unchecked
    append_errors('checkbox.unchecked', {
        icon = { unchecked.icon, 'string' },
        highlight = { unchecked.highlight, 'string' },
    })
    local checked = checkbox.checked
    append_errors('checkbox.checked', {
        icon = { checked.icon, 'string' },
        highlight = { checked.highlight, 'string' },
    })
    for name, component in pairs(checkbox.custom) do
        append_errors('checkbox.custom.' .. name, {
            raw = { component.raw, 'string' },
            rendered = { component.rendered, 'string' },
            highlight = { component.highlight, 'string' },
        })
    end

    local quote = config.quote
    append_errors('quote', {
        icon = { quote.icon, 'string' },
        highlight = { quote.highlight, 'string' },
    })

    local pipe_table = config.pipe_table
    append_errors('pipe_table', {
        style = one_of(pipe_table.style, { 'full', 'normal', 'none' }),
        cell = one_of(pipe_table.cell, { 'overlay', 'raw' }),
        boarder = { pipe_table.boarder, 'table' },
        head = { pipe_table.head, 'string' },
        row = { pipe_table.row, 'string' },
    })
    all_strings('pipe_table.boarder', pipe_table.boarder)

    for name, component in pairs(config.callout) do
        append_errors('callout.' .. name, {
            raw = { component.raw, 'string' },
            rendered = { component.rendered, 'string' },
            highlight = { component.highlight, 'string' },
        })
    end

    for name, win_option in pairs(config.win_options) do
        append_errors('win_options.' .. name, {
            default = { win_option.default, { 'number', 'string' } },
            rendered = { win_option.rendered, { 'number', 'string' } },
        })
    end

    for name, handler in pairs(config.custom_handlers) do
        append_errors('custom_handlers.' .. name, {
            render = { handler.render, 'function' },
            extends = { handler.extends, 'boolean', true },
        })
    end

    return errors
end

return M
