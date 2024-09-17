local Config = require('render-markdown.config')
local log = require('render-markdown.core.log')
local presets = require('render-markdown.presets')
local treesitter = require('render-markdown.core.treesitter')
local util = require('render-markdown.core.util')

---@type table<integer, render.md.buffer.Config>
local configs = {}

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field file_types string[]
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
    -- Override settings that require neovim >= 0.10.0 and have compatible alternatives
    if not util.has_10 then
        config.code.position = 'right'
        config.checkbox.position = 'overlay'
    end

    M.config = config
    M.enabled = config.enabled
    M.file_types = config.file_types
    M.latex = config.latex
    M.custom_handlers = config.custom_handlers
    vim.schedule(function()
        M.markdown_query = vim.treesitter.query.parse('markdown', config.markdown_query)
        M.markdown_quote_query = vim.treesitter.query.parse('markdown', config.markdown_quote_query)
        M.inline_query = vim.treesitter.query.parse('markdown_inline', config.inline_query)
    end)
    log.setup(config.log_level)
    for _, language in ipairs(M.file_types) do
        treesitter.inject(language, config.injections[language])
    end
end

function M.invalidate_cache()
    configs = {}
end

---@param amount integer
function M.modify_anti_conceal(amount)
    ---@param anti_conceal render.md.AntiConceal
    local function modify(anti_conceal)
        anti_conceal.above = math.max(anti_conceal.above + amount, 0)
        anti_conceal.below = math.max(anti_conceal.below + amount, 0)
    end
    modify(M.config.anti_conceal)
    for _, config in pairs(configs) do
        modify(config.anti_conceal)
    end
end

---@param buf integer
---@return render.md.buffer.Config
function M.get_config(buf)
    local config = configs[buf]
    if config == nil then
        local buf_config = M.default_buffer_config()
        for _, name in ipairs({ 'buftype', 'filetype' }) do
            local override = M.config.overrides[name][util.get_buf(buf, name)]
            if override ~= nil then
                buf_config = vim.tbl_deep_extend('force', buf_config, override)
            end
        end
        config = Config.new(buf_config)
        configs[buf] = config
    end
    return config
end

---@private
---@return render.md.BufferConfig
function M.default_buffer_config()
    local config = M.config
    ---@type render.md.BufferConfig
    local buffer_config = {
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
        indent = config.indent,
        win_options = config.win_options,
    }
    return vim.deepcopy(buffer_config)
end

---@return string[]
function M.validate()
    ---@param types type[]
    ---@param nilable boolean
    ---@return string
    local function handle_types(types, nilable)
        if nilable then
            table.insert(types, 'nil')
        end
        return #types == 0 and '' or (' or type ' .. vim.inspect(types))
    end

    ---@param value any
    ---@param values string[]
    ---@param types type[]
    ---@param nilable boolean
    ---@return vim.validate.Spec
    local function one_of(value, values, types, nilable)
        local suffix = handle_types(types, nilable)
        return {
            value,
            function(v)
                return vim.tbl_contains(values, v) or vim.tbl_contains(types, type(v))
            end,
            'one of ' .. vim.inspect(values) .. suffix,
        }
    end

    ---@param value any
    ---@param values string[]
    ---@param types type[]
    ---@param nilable boolean
    ---@return vim.validate.Spec
    local function one_or_array_of(value, values, types, nilable)
        local suffix = handle_types(types, nilable)
        return {
            value,
            function(v)
                if vim.tbl_contains(types, type(v)) then
                    return true
                elseif type(v) == 'string' then
                    return vim.tbl_contains(values, v)
                elseif type(v) == 'table' then
                    for i, item in ipairs(v) do
                        if not vim.tbl_contains(values, item) then
                            return false, string.format('Index %d is %s', i, item)
                        end
                    end
                    return true
                else
                    return false
                end
            end,
            'one or array of ' .. vim.inspect(values) .. suffix,
        }
    end

    ---@param value any
    ---@param types type[]
    ---@param nilable boolean
    ---@return vim.validate.Spec
    local function string_array(value, types, nilable)
        local suffix = handle_types(types, nilable)
        return {
            value,
            function(v)
                if vim.tbl_contains(types, type(v)) then
                    return true
                elseif type(v) == 'table' then
                    for i, item in ipairs(v) do
                        if type(item) ~= 'string' then
                            return false, string.format('Index %d is %s', i, type(item))
                        end
                    end
                    return true
                else
                    return false
                end
            end,
            'string array' .. suffix,
        }
    end

    local errors = {}

    ---@param suffix string
    ---@param input table<string, any>
    ---@param opts table<string, vim.validate.Spec>
    local function append_errors(suffix, input, opts)
        local path = 'render-markdown' .. suffix
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
                above = { anti_conceal.above, 'number', nilable },
                below = { anti_conceal.below, 'number', nilable },
            })
        end

        local heading = config.heading
        if heading ~= nil then
            append_errors(path .. '.heading', heading, {
                enabled = { heading.enabled, 'boolean', nilable },
                sign = { heading.sign, 'boolean', nilable },
                position = one_of(heading.position, { 'overlay', 'inline' }, {}, nilable),
                icons = string_array(heading.icons, {}, nilable),
                signs = string_array(heading.signs, {}, nilable),
                width = one_or_array_of(heading.width, { 'full', 'block' }, {}, nilable),
                left_pad = { heading.left_pad, 'number', nilable },
                right_pad = { heading.right_pad, 'number', nilable },
                min_width = { heading.min_width, 'number', nilable },
                border = { heading.border, 'boolean', nilable },
                border_prefix = { heading.border_prefix, 'boolean', nilable },
                above = { heading.above, 'string', nilable },
                below = { heading.below, 'string', nilable },
                backgrounds = string_array(heading.backgrounds, {}, nilable),
                foregrounds = string_array(heading.foregrounds, {}, nilable),
            })
        end

        local code = config.code
        if code ~= nil then
            append_errors(path .. '.code', code, {
                enabled = { code.enabled, 'boolean', nilable },
                sign = { code.sign, 'boolean', nilable },
                style = one_of(code.style, { 'full', 'normal', 'language', 'none' }, {}, nilable),
                position = one_of(code.position, { 'left', 'right' }, {}, nilable),
                language_pad = { code.language_pad, 'number', nilable },
                disable_background = string_array(code.disable_background, {}, nilable),
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
                icons = string_array(bullet.icons, {}, nilable),
                left_pad = { bullet.left_pad, 'number', nilable },
                right_pad = { bullet.right_pad, 'number', nilable },
                highlight = { bullet.highlight, 'string', nilable },
            })
        end

        local checkbox = config.checkbox
        if checkbox ~= nil then
            append_errors(path .. '.checkbox', checkbox, {
                enabled = { checkbox.enabled, 'boolean', nilable },
                position = one_of(checkbox.position, { 'overlay', 'inline' }, {}, nilable),
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
                preset = one_of(pipe_table.preset, { 'none', 'round', 'double', 'heavy' }, {}, nilable),
                style = one_of(pipe_table.style, { 'full', 'normal', 'none' }, {}, nilable),
                cell = one_of(pipe_table.cell, { 'padded', 'raw', 'overlay' }, {}, nilable),
                min_width = { pipe_table.min_width, 'number', nilable },
                border = string_array(pipe_table.border, {}, nilable),
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
                email = { link.email, 'string', nilable },
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

        local indent = config.indent
        if indent ~= nil then
            append_errors(path .. '.indent', indent, {
                enabled = { indent.enabled, 'boolean', nilable },
                per_level = { indent.per_level, 'number', nilable },
                skip_level = { indent.skip_level, 'number', nilable },
                skip_heading = { indent.skip_heading, 'boolean', nilable },
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
    append_errors('', config, {
        enabled = { config.enabled, 'boolean' },
        max_file_size = { config.max_file_size, 'number' },
        debounce = { config.debounce, 'number' },
        render_modes = string_array(config.render_modes, { 'boolean' }, false),
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
        indent = { config.indent, 'table' },
        win_options = { config.win_options, 'table' },
        preset = one_of(config.preset, { 'none', 'lazy', 'obsidian' }, {}, false),
        markdown_query = { config.markdown_query, 'string' },
        markdown_quote_query = { config.markdown_quote_query, 'string' },
        inline_query = { config.inline_query, 'string' },
        log_level = one_of(config.log_level, { 'debug', 'error' }, {}, false),
        file_types = string_array(config.file_types, {}, false),
        injections = { config.injections, 'table' },
        latex = { config.latex, 'table' },
        overrides = { config.overrides, 'table' },
        custom_handlers = { config.custom_handlers, 'table' },
    })

    validate_buffer_config('', config, false)

    local injections = config.injections
    for name, injection in pairs(injections) do
        append_errors('.injections.' .. name, injection, {
            enabled = { injection.enabled, 'boolean' },
            query = { injection.query, 'string' },
        })
    end

    local latex = config.latex
    append_errors('.latex', latex, {
        enabled = { latex.enabled, 'boolean' },
        converter = { latex.converter, 'string' },
        highlight = { latex.highlight, 'string' },
        top_pad = { latex.top_pad, 'number' },
        bottom_pad = { latex.bottom_pad, 'number' },
    })

    local overrides = config.overrides
    append_errors('.overrides', overrides, {
        buftype = { overrides.buftype, 'table' },
        filetype = { overrides.filetype, 'table' },
    })
    for name, value_override in pairs(overrides) do
        for value, override in pairs(value_override) do
            local path = string.format('.overrides.%s.%s', name, value)
            append_errors(path, override, {
                enabled = { override.enabled, 'boolean', true },
                max_file_size = { override.max_file_size, 'number', true },
                debounce = { override.debounce, 'number', true },
                render_modes = string_array(override.render_modes, {}, true),
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
                indent = { override.indent, 'table', true },
                win_options = { override.win_options, 'table', true },
            })
            validate_buffer_config(path, override, true)
        end
    end

    for name, handler in pairs(config.custom_handlers) do
        append_errors('.custom_handlers.' .. name, handler, {
            parse = { handler.parse, 'function' },
            extends = { handler.extends, 'boolean', true },
        })
    end

    return errors
end

return M
