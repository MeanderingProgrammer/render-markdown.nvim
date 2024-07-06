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
        start_enabled = { config.start_enabled, 'boolean' },
        latex_enabled = { config.latex_enabled, 'boolean' },
        max_file_size = { config.max_file_size, 'number' },
        markdown_query = { config.markdown_query, 'string' },
        markdown_quote_query = { config.markdown_quote_query, 'string' },
        inline_query = { config.inline_query, 'string' },
        latex_converter = { config.latex_converter, 'string' },
        log_level = one_of(config.log_level, { 'debug', 'error' }),
        file_types = { config.file_types, 'table' },
        render_modes = { config.render_modes, 'table' },
        headings = { config.headings, 'table' },
        dash = { config.dash, 'string' },
        bullets = { config.bullets, 'table' },
        checkbox = { config.checkbox, 'table' },
        quote = { config.quote, 'string' },
        callout = { config.callout, 'table' },
        win_options = { config.win_options, 'table' },
        code_style = one_of(config.code_style, { 'full', 'normal', 'none' }),
        table_style = one_of(config.table_style, { 'full', 'normal', 'none' }),
        cell_style = one_of(config.cell_style, { 'overlay', 'raw' }),
        custom_handlers = { config.custom_handlers, 'table' },
        highlights = { config.highlights, 'table' },
    })

    all_strings('file_types', config.file_types)
    all_strings('render_modes', config.render_modes)
    all_strings('headings', config.headings)
    all_strings('bullets', config.bullets)

    append_errors('checkbox', {
        unchecked = { config.checkbox.unchecked, 'string' },
        checked = { config.checkbox.checked, 'string' },
        custom = { config.checkbox.custom, 'table' },
    })
    for name, component in pairs(config.checkbox.custom) do
        append_errors('checkbox.custom.' .. name, {
            raw = { component.raw, 'string' },
            rendered = { component.rendered, 'string' },
            highlight = { component.highlight, 'string' },
        })
    end

    append_errors('callout', {
        note = { config.callout.note, 'string' },
        tip = { config.callout.tip, 'string' },
        important = { config.callout.important, 'string' },
        warning = { config.callout.warning, 'string' },
        caution = { config.callout.caution, 'string' },
        custom = { config.callout.custom, 'table' },
    })
    for name, component in pairs(config.callout.custom) do
        append_errors('callout.custom.' .. name, {
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

    append_errors('highlights', {
        heading = { config.highlights.heading, 'table' },
        dash = { config.highlights.dash, 'string' },
        code = { config.highlights.code, 'string' },
        bullet = { config.highlights.bullet, 'string' },
        checkbox = { config.highlights.checkbox, 'table' },
        table = { config.highlights.table, 'table' },
        latex = { config.highlights.latex, 'string' },
        quote = { config.highlights.quote, 'string' },
        callout = { config.highlights.callout, 'table' },
    })

    append_errors('highlights.heading', {
        backgrounds = { config.highlights.heading.backgrounds, 'table' },
        foregrounds = { config.highlights.heading.foregrounds, 'table' },
    })
    all_strings('highlights.heading.backgrounds', config.highlights.heading.backgrounds)
    all_strings('highlights.heading.foregrounds', config.highlights.heading.foregrounds)

    append_errors('highlights.checkbox', {
        unchecked = { config.highlights.checkbox.unchecked, 'string' },
        checked = { config.highlights.checkbox.checked, 'string' },
    })

    append_errors('highlights.table', {
        head = { config.highlights.table.head, 'string' },
        row = { config.highlights.table.row, 'string' },
    })

    append_errors('highlights.callout', {
        note = { config.highlights.callout.note, 'string' },
        tip = { config.highlights.callout.tip, 'string' },
        important = { config.highlights.callout.important, 'string' },
        warning = { config.highlights.callout.warning, 'string' },
        caution = { config.highlights.callout.caution, 'string' },
    })

    return errors
end

return M
