---@class render.md.State
---@field config render.md.Config
---@field enabled boolean
---@field markdown_query vim.treesitter.Query
---@field markdown_quote_query vim.treesitter.Query
---@field inline_query vim.treesitter.Query
---@field inline_link_query vim.treesitter.Query
local state = {}

---@return string[]
function state.validate()
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

    ---@param value string[]
    ---@return vim.validate.Spec
    local function string_array(value)
        return {
            value,
            function(v)
                if type(v) ~= 'table' then
                    return false
                end
                for i, item in ipairs(v) do
                    if type(item) ~= 'string' then
                        return false, string.format('Index %d is %s', i, type(item))
                    end
                end
                return true
            end,
            'string array',
        }
    end

    ---@param path string
    ---@param input table<string, any>
    ---@param opts table<string, vim.validate.Spec>
    local function append_errors(path, input, opts)
        local ok, err = pcall(vim.validate, opts)
        if not ok then
            table.insert(errors, path .. '.' .. err)
        end
        for key, _ in pairs(input) do
            if opts[key] == nil then
                table.insert(errors, string.format('%s.%s: is not a valid key', path, key))
            end
        end
    end

    local config = state.config
    append_errors('render-markdown', config, {
        enabled = { config.enabled, 'boolean' },
        max_file_size = { config.max_file_size, 'number' },
        markdown_query = { config.markdown_query, 'string' },
        markdown_quote_query = { config.markdown_quote_query, 'string' },
        inline_query = { config.inline_query, 'string' },
        inline_link_query = { config.inline_link_query, 'string' },
        log_level = one_of(config.log_level, { 'debug', 'error' }),
        file_types = string_array(config.file_types),
        render_modes = string_array(config.render_modes),
        exclude = { config.exclude, 'table' },
        anti_conceal = { config.anti_conceal, 'table' },
        latex = { config.latex, 'table' },
        heading = { config.heading, 'table' },
        code = { config.code, 'table' },
        dash = { config.dash, 'table' },
        bullet = { config.bullet, 'table' },
        pipe_table = { config.pipe_table, 'table' },
        checkbox = { config.checkbox, 'table' },
        quote = { config.quote, 'table' },
        callout = { config.callout, 'table' },
        link = { config.link, 'table' },
        sign = { config.sign, 'table' },
        win_options = { config.win_options, 'table' },
        custom_handlers = { config.custom_handlers, 'table' },
    })

    local exclude = config.exclude
    append_errors('render-markdown.exclude', exclude, {
        buftypes = string_array(exclude.buftypes),
    })

    local anti_conceal = config.anti_conceal
    append_errors('render-markdown.anti_conceal', anti_conceal, {
        enabled = { anti_conceal.enabled, 'boolean' },
    })

    local latex = config.latex
    append_errors('render-markdown.latex', latex, {
        enabled = { latex.enabled, 'boolean' },
        converter = { latex.converter, 'string' },
        highlight = { latex.highlight, 'string' },
    })

    local heading = config.heading
    append_errors('render-markdown.heading', heading, {
        enabled = { heading.enabled, 'boolean' },
        sign = { heading.sign, 'boolean' },
        icons = string_array(heading.icons),
        signs = string_array(heading.signs),
        backgrounds = string_array(heading.backgrounds),
        foregrounds = string_array(heading.foregrounds),
    })

    local code = config.code
    append_errors('render-markdown.code', code, {
        enabled = { code.enabled, 'boolean' },
        sign = { code.sign, 'boolean' },
        style = one_of(code.style, { 'full', 'normal', 'language', 'none' }),
        left_pad = { code.left_pad, 'number' },
        border = one_of(code.border, { 'thin', 'thick' }),
        above = { code.above, 'string' },
        below = { code.below, 'string' },
        highlight = { code.highlight, 'string' },
    })

    local dash = config.dash
    append_errors('render-markdown.dash', dash, {
        enabled = { dash.enabled, 'boolean' },
        icon = { dash.icon, 'string' },
        highlight = { dash.highlight, 'string' },
    })

    local bullet = config.bullet
    append_errors('render-markdown.bullet', bullet, {
        enabled = { bullet.enabled, 'boolean' },
        icons = string_array(bullet.icons),
        highlight = { bullet.highlight, 'string' },
    })

    local checkbox = config.checkbox
    append_errors('render-markdown.checkbox', checkbox, {
        enabled = { checkbox.enabled, 'boolean' },
        unchecked = { checkbox.unchecked, 'table' },
        checked = { checkbox.checked, 'table' },
        custom = { checkbox.custom, 'table' },
    })
    local unchecked = checkbox.unchecked
    append_errors('render-markdown.checkbox.unchecked', unchecked, {
        icon = { unchecked.icon, 'string' },
        highlight = { unchecked.highlight, 'string' },
    })
    local checked = checkbox.checked
    append_errors('render-markdown.checkbox.checked', checked, {
        icon = { checked.icon, 'string' },
        highlight = { checked.highlight, 'string' },
    })
    for name, component in pairs(checkbox.custom) do
        append_errors('render-markdown.checkbox.custom.' .. name, component, {
            raw = { component.raw, 'string' },
            rendered = { component.rendered, 'string' },
            highlight = { component.highlight, 'string' },
        })
    end

    local quote = config.quote
    append_errors('render-markdown.quote', quote, {
        enabled = { quote.enabled, 'boolean' },
        icon = { quote.icon, 'string' },
        highlight = { quote.highlight, 'string' },
    })

    local pipe_table = config.pipe_table
    append_errors('render-markdown.pipe_table', pipe_table, {
        enabled = { pipe_table.enabled, 'boolean' },
        style = one_of(pipe_table.style, { 'full', 'normal', 'none' }),
        cell = one_of(pipe_table.cell, { 'padded', 'raw', 'overlay' }),
        border = string_array(pipe_table.border),
        head = { pipe_table.head, 'string' },
        row = { pipe_table.row, 'string' },
        filler = { pipe_table.filler, 'string' },
    })

    for name, component in pairs(config.callout) do
        append_errors('render-markdown.callout.' .. name, component, {
            raw = { component.raw, 'string' },
            rendered = { component.rendered, 'string' },
            highlight = { component.highlight, 'string' },
        })
    end

    local link = config.link
    append_errors('render-markdown.link', link, {
        enabled = { link.enabled, 'boolean' },
        image = { link.image, 'string' },
        hyperlink = { link.hyperlink, 'string' },
        highlight = { link.highlight, 'string' },
    })

    local sign = config.sign
    append_errors('render-markdown.sign', sign, {
        enabled = { sign.enabled, 'boolean' },
        exclude = { sign.exclude, 'table' },
        highlight = { sign.highlight, 'string' },
    })
    local sign_exclude = sign.exclude
    append_errors('render-markdown.sign.exclude', sign_exclude, {
        buftypes = string_array(sign_exclude.buftypes),
    })

    for name, win_option in pairs(config.win_options) do
        append_errors('render-markdown.win_options.' .. name, win_option, {
            default = { win_option.default, { 'number', 'string' } },
            rendered = { win_option.rendered, { 'number', 'string' } },
        })
    end

    for name, handler in pairs(config.custom_handlers) do
        append_errors('render-markdown.custom_handlers.' .. name, handler, {
            parse = { handler.parse, 'function' },
            extends = { handler.extends, 'boolean', true },
        })
    end

    return errors
end

return state
