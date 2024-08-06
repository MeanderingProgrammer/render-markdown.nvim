local presets = require('render-markdown.presets')
local util = require('render-markdown.util')

---@type table<integer, render.md.BufferConfig>
local configs = {}

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field log_level 'debug'|'error'
---@field file_types string[]
---@field acknowledge_conflicts boolean
---@field latex render.md.Latex
---@field custom_handlers table<string, render.md.Handler>
---@field markdown_query vim.treesitter.Query
---@field markdown_quote_query vim.treesitter.Query
---@field inline_query vim.treesitter.Query
local M = {}

---@return boolean
function M.initialized()
    return M.config ~= nil
end

---@param default_config render.md.Config
---@param user_config render.md.UserConfig
function M.setup(default_config, user_config)
    local config = vim.tbl_deep_extend('force', default_config, presets.get(user_config), user_config)
    M.config = config
    M.enabled = config.enabled
    M.log_level = config.log_level
    M.file_types = config.file_types
    M.acknowledge_conflicts = config.acknowledge_conflicts
    M.latex = config.latex
    M.custom_handlers = config.custom_handlers
    vim.schedule(function()
        M.markdown_query = vim.treesitter.query.parse('markdown', config.markdown_query)
        M.markdown_quote_query = vim.treesitter.query.parse('markdown', config.markdown_quote_query)
        M.inline_query = vim.treesitter.query.parse('markdown_inline', config.inline_query)
    end)
end

function M.invalidate_cache()
    configs = {}
end

---@param buf integer
---@return render.md.BufferConfig
M.get_config = function(buf)
    local config = configs[buf]
    if config == nil then
        config = M.default_buffer_config()
        local buftype_config = M.config.overrides.buftype[util.get_buf(buf, 'buftype')]
        if buftype_config ~= nil then
            config = vim.tbl_deep_extend('force', config, buftype_config)
        end
        configs[buf] = config
    end
    return config
end

---@private
---@return render.md.BufferConfig
function M.default_buffer_config()
    local config = M.config
    ---@type render.md.BufferConfig
    return {
        enabled = true,
        max_file_size = config.max_file_size,
        debounce = config.debounce,
        render_modes = config.render_modes,
        anti_conceal = config.anti_conceal,
        heading = config.heading,
        code = config.code,
        dash = config.dash,
        bullet = config.bullet,
        checkbox = config.checkbox,
        quote = config.quote,
        pipe_table = config.pipe_table,
        callout = config.callout,
        link = config.link,
        sign = config.sign,
        win_options = config.win_options,
    }
end

---@return string[]
function M.validate()
    local errors = {}

    ---@param value any
    ---@param valid_values string[]
    ---@param valid_types type[]
    ---@param nilable boolean
    ---@return vim.validate.Spec
    local function one_of(value, valid_values, valid_types, nilable)
        if nilable then
            table.insert(valid_types, 'nil')
        end
        return {
            value,
            function(v)
                return vim.tbl_contains(valid_values, v) or vim.tbl_contains(valid_types, type(v))
            end,
            'one of ' .. vim.inspect(valid_values) .. ' or type ' .. vim.inspect(valid_types),
        }
    end

    ---@param value string[]
    ---@param nilable boolean
    ---@return vim.validate.Spec
    local function string_array(value, nilable)
        local description = 'string array'
        if nilable then
            description = description .. ' or nil'
        end
        return {
            value,
            function(v)
                if v == nil then
                    return nilable
                elseif type(v) ~= 'table' then
                    return false
                else
                    for i, item in ipairs(v) do
                        if type(item) ~= 'string' then
                            return false, string.format('Index %d is %s', i, type(item))
                        end
                    end
                    return true
                end
            end,
            description,
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

    ---@param path string
    ---@param config render.md.BufferConfig|render.md.UserBufferConfig
    ---@param nilable boolean
    local function validate_buffer_config(path, config, nilable)
        local anti_conceal = config.anti_conceal
        if anti_conceal ~= nil then
            append_errors(path .. '.anti_conceal', anti_conceal, {
                enabled = { anti_conceal.enabled, 'boolean', nilable },
            })
        end

        local heading = config.heading
        if heading ~= nil then
            append_errors(path .. '.heading', heading, {
                enabled = { heading.enabled, 'boolean', nilable },
                sign = { heading.sign, 'boolean', nilable },
                position = one_of(heading.position, { 'overlay', 'inline' }, {}, nilable),
                icons = string_array(heading.icons, nilable),
                signs = string_array(heading.signs, nilable),
                width = one_of(heading.width, { 'full', 'block' }, {}, nilable),
                left_pad = { heading.left_pad, 'number', nilable },
                right_pad = { heading.right_pad, 'number', nilable },
                min_width = { heading.min_width, 'number', nilable },
                backgrounds = string_array(heading.backgrounds, nilable),
                foregrounds = string_array(heading.foregrounds, nilable),
            })
        end

        local code = config.code
        if code ~= nil then
            append_errors(path .. '.code', code, {
                enabled = { code.enabled, 'boolean', nilable },
                sign = { code.sign, 'boolean', nilable },
                style = one_of(code.style, { 'full', 'normal', 'language', 'none' }, {}, nilable),
                position = one_of(code.position, { 'left', 'right' }, {}, nilable),
                disable_background = string_array(code.disable_background, nilable),
                width = one_of(code.width, { 'full', 'block' }, {}, nilable),
                left_pad = { code.left_pad, 'number', nilable },
                right_pad = { code.right_pad, 'number', nilable },
                min_width = { code.min_width, 'number', nilable },
                border = one_of(code.border, { 'thin', 'thick' }, {}, nilable),
                above = { code.above, 'string', nilable },
                below = { code.below, 'string', nilable },
                highlight = { code.highlight, 'string', nilable },
                highlight_inline = { code.highlight_inline, 'string', nilable },
            })
        end

        local dash = config.dash
        if dash ~= nil then
            append_errors(path .. '.dash', dash, {
                enabled = { dash.enabled, 'boolean', nilable },
                icon = { dash.icon, 'string', nilable },
                width = one_of(dash.width, { 'full' }, { 'number' }, nilable),
                highlight = { dash.highlight, 'string', nilable },
            })
        end

        local bullet = config.bullet
        if bullet ~= nil then
            append_errors(path .. '.bullet', bullet, {
                enabled = { bullet.enabled, 'boolean', nilable },
                icons = string_array(bullet.icons, nilable),
                left_pad = { bullet.left_pad, 'number', nilable },
                right_pad = { bullet.right_pad, 'number', nilable },
                highlight = { bullet.highlight, 'string', nilable },
            })
        end

        local checkbox = config.checkbox
        if checkbox ~= nil then
            append_errors(path .. '.checkbox', checkbox, {
                enabled = { checkbox.enabled, 'boolean', nilable },
                unchecked = { checkbox.unchecked, 'table', nilable },
                checked = { checkbox.checked, 'table', nilable },
                custom = { checkbox.custom, 'table', nilable },
            })
            local unchecked = checkbox.unchecked
            if unchecked ~= nil then
                append_errors(path .. '.checkbox.unchecked', unchecked, {
                    icon = { unchecked.icon, 'string', nilable },
                    highlight = { unchecked.highlight, 'string', nilable },
                })
            end
            local checked = checkbox.checked
            if checked ~= nil then
                append_errors(path .. '.checkbox.checked', checked, {
                    icon = { checked.icon, 'string', nilable },
                    highlight = { checked.highlight, 'string', nilable },
                })
            end
            if checkbox.custom ~= nil then
                for name, component in pairs(checkbox.custom) do
                    append_errors(path .. '.checkbox.custom.' .. name, component, {
                        raw = { component.raw, 'string' },
                        rendered = { component.rendered, 'string' },
                        highlight = { component.highlight, 'string' },
                    })
                end
            end
        end

        local quote = config.quote
        if quote ~= nil then
            append_errors(path .. '.quote', quote, {
                enabled = { quote.enabled, 'boolean', nilable },
                icon = { quote.icon, 'string', nilable },
                repeat_linebreak = { quote.repeat_linebreak, 'boolean', nilable },
                highlight = { quote.highlight, 'string', nilable },
            })
        end

        local pipe_table = config.pipe_table
        if pipe_table ~= nil then
            append_errors(path .. '.pipe_table', pipe_table, {
                enabled = { pipe_table.enabled, 'boolean', nilable },
                style = one_of(pipe_table.style, { 'full', 'normal', 'none' }, {}, nilable),
                cell = one_of(pipe_table.cell, { 'padded', 'raw', 'overlay' }, {}, nilable),
                border = string_array(pipe_table.border, nilable),
                alignment_indicator = { pipe_table.alignment_indicator, 'string', nilable },
                head = { pipe_table.head, 'string', nilable },
                row = { pipe_table.row, 'string', nilable },
                filler = { pipe_table.filler, 'string', nilable },
            })
        end

        if config.callout ~= nil then
            for name, component in pairs(config.callout) do
                append_errors(path .. '.callout.' .. name, component, {
                    raw = { component.raw, 'string' },
                    rendered = { component.rendered, 'string' },
                    highlight = { component.highlight, 'string' },
                })
            end
        end

        local link = config.link
        if link ~= nil then
            append_errors(path .. '.link', link, {
                enabled = { link.enabled, 'boolean', nilable },
                image = { link.image, 'string', nilable },
                hyperlink = { link.hyperlink, 'string', nilable },
                highlight = { link.highlight, 'string', nilable },
                custom = { link.custom, 'table', nilable },
            })
            if link.custom ~= nil then
                for name, component in pairs(link.custom) do
                    append_errors(path .. '.link.custom.' .. name, component, {
                        pattern = { component.pattern, 'string' },
                        icon = { component.icon, 'string' },
                        highlight = { component.highlight, 'string' },
                    })
                end
            end
        end

        local sign = config.sign
        if sign ~= nil then
            append_errors(path .. '.sign', sign, {
                enabled = { sign.enabled, 'boolean', nilable },
                highlight = { sign.highlight, 'string', nilable },
            })
        end

        if config.win_options ~= nil then
            for name, win_option in pairs(config.win_options) do
                append_errors(path .. '.win_options.' .. name, win_option, {
                    default = { win_option.default, { 'number', 'string', 'boolean' } },
                    rendered = { win_option.rendered, { 'number', 'string', 'boolean' } },
                })
            end
        end
    end

    local config = M.config
    append_errors('render-markdown', config, {
        enabled = { config.enabled, 'boolean' },
        max_file_size = { config.max_file_size, 'number' },
        debounce = { config.debounce, 'number' },
        render_modes = string_array(config.render_modes, false),
        anti_conceal = { config.anti_conceal, 'table' },
        heading = { config.heading, 'table' },
        code = { config.code, 'table' },
        dash = { config.dash, 'table' },
        bullet = { config.bullet, 'table' },
        checkbox = { config.checkbox, 'table' },
        quote = { config.quote, 'table' },
        pipe_table = { config.pipe_table, 'table' },
        callout = { config.callout, 'table' },
        link = { config.link, 'table' },
        sign = { config.sign, 'table' },
        win_options = { config.win_options, 'table' },
        preset = one_of(config.preset, { 'none', 'lazy', 'obsidian' }, {}, false),
        markdown_query = { config.markdown_query, 'string' },
        markdown_quote_query = { config.markdown_quote_query, 'string' },
        inline_query = { config.inline_query, 'string' },
        log_level = one_of(config.log_level, { 'debug', 'error' }, {}, false),
        file_types = string_array(config.file_types, false),
        acknowledge_conflicts = { config.acknowledge_conflicts, 'boolean' },
        latex = { config.latex, 'table' },
        overrides = { config.overrides, 'table' },
        custom_handlers = { config.custom_handlers, 'table' },
    })

    validate_buffer_config('render-markdown', config, false)

    local latex = config.latex
    append_errors('render-markdown.latex', latex, {
        enabled = { latex.enabled, 'boolean' },
        converter = { latex.converter, 'string' },
        highlight = { latex.highlight, 'string' },
        top_pad = { latex.top_pad, 'number' },
        bottom_pad = { latex.bottom_pad, 'number' },
    })

    local overrides = config.overrides
    append_errors('render-markdown.overrides', overrides, {
        buftype = { overrides.buftype, 'table' },
    })
    for name, override in pairs(overrides.buftype) do
        local path = 'render-markdown.overrides.buftype.' .. name
        append_errors(path, override, {
            enabled = { override.enabled, 'boolean', true },
            max_file_size = { override.max_file_size, 'number', true },
            debounce = { override.debounce, 'number', true },
            render_modes = string_array(override.render_modes, true),
            anti_conceal = { override.anti_conceal, 'table', true },
            heading = { override.heading, 'table', true },
            code = { override.code, 'table', true },
            dash = { override.dash, 'table', true },
            bullet = { override.bullet, 'table', true },
            checkbox = { override.checkbox, 'table', true },
            quote = { override.quote, 'table', true },
            pipe_table = { override.pipe_table, 'table', true },
            callout = { override.callout, 'table', true },
            link = { override.link, 'table', true },
            sign = { override.sign, 'table', true },
            win_options = { override.win_options, 'table', true },
        })
        validate_buffer_config(path, override, true)
    end

    for name, handler in pairs(config.custom_handlers) do
        append_errors('render-markdown.custom_handlers.' .. name, handler, {
            parse = { handler.parse, 'function' },
            extends = { handler.extends, 'boolean', true },
        })
    end

    return errors
end

return M
