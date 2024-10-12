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
---@field log_runtime boolean
---@field file_types string[]
---@field latex render.md.Latex
---@field on render.md.Callback
---@field custom_handlers table<string, render.md.Handler>
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
    -- Use lazy.nvim file type configuration if available and no user value is specified
    if user_config.file_types == nil then
        local lazy_file_types = util.lazy_file_types('render-markdown.nvim')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end

    M.config = config
    M.enabled = config.enabled
    M.log_runtime = config.log_runtime
    M.file_types = config.file_types
    M.latex = config.latex
    M.on = config.on
    M.custom_handlers = config.custom_handlers
    log.setup(config.log_level)
    for _, language in ipairs(M.file_types) do
        treesitter.inject(language, config.injections[language])
    end
end

function M.invalidate_cache()
    configs = {}
end

---@param default_config render.md.Config
---@return table
function M.difference(default_config)
    return require('render-markdown.debug.diff').get(default_config, M.config)
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
function M.get(buf)
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
        padding = config.padding,
        heading = config.heading,
        paragraph = config.paragraph,
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
    local validator = require('render-markdown.debug.validator').new()

    ---@param config render.md.BufferConfig|render.md.UserBufferConfig
    ---@param nilable boolean
    ---@param path? string
    local function validate_buffer_config(config, nilable, path)
        ---@param key string|string[]
        ---@return render.md.debug.ValidatorSpec
        local function get_spec(key)
            return validator:spec(config, nilable, key, path)
        end

        get_spec('anti_conceal'):type('enabled', 'boolean'):type({ 'above', 'below' }, 'number'):check()

        get_spec('padding'):type('highlight', 'string'):check()

        get_spec('heading')
            :type({ 'enabled', 'sign', 'border', 'border_virtual', 'border_prefix' }, 'boolean')
            :type({ 'above', 'below' }, 'string')
            :list({ 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number', 'number')
            :list({ 'icons', 'signs', 'backgrounds', 'foregrounds' }, 'string')
            :one_of('position', { 'overlay', 'inline' })
            :one_or_list_of('width', { 'full', 'block' })
            :check()

        get_spec('paragraph'):type('enabled', 'boolean'):type({ 'left_margin', 'min_width' }, 'number'):check()

        get_spec('code')
            :type({ 'enabled', 'sign' }, 'boolean')
            :type({ 'language_pad', 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number')
            :type({ 'above', 'below', 'highlight', 'highlight_inline' }, 'string')
            :type('highlight_language', { 'string', 'nil' })
            :list('disable_background', 'string')
            :one_of('style', { 'full', 'normal', 'language', 'none' })
            :one_of('position', { 'left', 'right' })
            :one_of('width', { 'full', 'block' })
            :one_of('border', { 'thin', 'thick' })
            :check()

        get_spec('dash')
            :type('enabled', 'boolean')
            :type({ 'icon', 'highlight' }, 'string')
            :one_of('width', { 'full' }, 'number')
            :check()

        get_spec('bullet')
            :type('enabled', 'boolean')
            :type({ 'left_pad', 'right_pad' }, 'number')
            :type('highlight', 'string')
            :list('icons', 'string')
            :check()

        get_spec('checkbox')
            :type('enabled', 'boolean')
            :type({ 'unchecked', 'checked', 'custom' }, 'table')
            :one_of('position', { 'overlay', 'inline' })
            :check()
        get_spec({ 'checkbox', 'unchecked' })
            :type({ 'icon', 'highlight' }, 'string')
            :type('scope_highlight', { 'string', 'nil' })
            :check()
        get_spec({ 'checkbox', 'checked' })
            :type({ 'icon', 'highlight' }, 'string')
            :type('scope_highlight', { 'string', 'nil' })
            :check()
        get_spec({ 'checkbox', 'custom' }):for_each(false, function(spec)
            spec:type({ 'raw', 'rendered', 'highlight' }, 'string')
        end)

        get_spec('quote')
            :type({ 'enabled', 'repeat_linebreak' }, 'boolean')
            :type({ 'icon', 'highlight' }, 'string')
            :check()

        get_spec('pipe_table')
            :type('enabled', 'boolean')
            :type('min_width', 'number')
            :type({ 'alignment_indicator', 'head', 'row', 'filler' }, 'string')
            :list('border', 'string')
            :one_of('preset', { 'none', 'round', 'double', 'heavy' })
            :one_of('style', { 'full', 'normal', 'none' })
            :one_of('cell', { 'trimmed', 'padded', 'raw', 'overlay' })
            :check()

        get_spec('callout'):for_each(false, function(spec)
            spec:type({ 'raw', 'rendered', 'highlight' }, 'string'):type('quote_icon', { 'string', 'nil' })
        end)

        get_spec('link')
            :type('enabled', 'boolean')
            :type({ 'image', 'email', 'hyperlink', 'highlight' }, 'string')
            :type({ 'wiki', 'custom' }, 'table')
            :check()
        get_spec({ 'link', 'wiki' }):type({ 'icon', 'highlight' }, 'string'):check()
        get_spec({ 'link', 'custom' }):for_each(false, function(spec)
            spec:type({ 'pattern', 'icon', 'highlight' }, 'string')
        end)

        get_spec('sign'):type('enabled', 'boolean'):type('highlight', 'string'):check()

        get_spec('indent')
            :type({ 'enabled', 'skip_heading' }, 'boolean')
            :type({ 'per_level', 'skip_level' }, 'number')
            :check()

        get_spec('win_options'):for_each(false, function(spec)
            spec:type({ 'default', 'rendered' }, { 'number', 'string', 'boolean' })
        end)
    end

    local config = M.config
    validator
        :spec(config, false)
        :type('enabled', 'boolean')
        :type({ 'max_file_size', 'debounce' }, 'number')
        :type({ 'anti_conceal', 'padding', 'heading', 'paragraph', 'code' }, 'table')
        :type({ 'dash', 'bullet', 'checkbox', 'quote', 'pipe_table' }, 'table')
        :type({ 'callout', 'link', 'sign', 'indent', 'win_options' }, 'table')
        :list('render_modes', 'string', 'boolean')
        :type('log_runtime', 'boolean')
        :type({ 'injections', 'latex', 'on', 'overrides', 'custom_handlers' }, 'table')
        :list('file_types', 'string')
        :one_of('preset', { 'none', 'lazy', 'obsidian' })
        :one_of('log_level', { 'debug', 'info', 'error' })
        :check()

    validate_buffer_config(config, false)

    validator:spec(config, false, 'injections'):for_each(false, function(spec)
        spec:type('enabled', 'boolean'):type('query', 'string')
    end)

    validator
        :spec(config, false, 'latex')
        :type('enabled', 'boolean')
        :type({ 'top_pad', 'bottom_pad' }, 'number')
        :type({ 'converter', 'highlight' }, 'string')
        :check()

    validator:spec(config, false, 'on'):type('attach', 'function'):check()

    validator:spec(config, false, 'overrides'):type({ 'buftype', 'filetype' }, 'table'):check()
    validator:spec(config, false, 'overrides'):for_each(false, function(override_spec)
        override_spec:for_each(true, function(spec)
            spec:type('enabled', 'boolean')
                :type({ 'max_file_size', 'debounce' }, 'number')
                :type({ 'anti_conceal', 'padding', 'heading', 'paragraph', 'code' }, 'table')
                :type({ 'dash', 'bullet', 'checkbox', 'quote', 'pipe_table' }, 'table')
                :type({ 'callout', 'link', 'sign', 'indent', 'win_options' }, 'table')
                :list('render_modes', 'string', 'boolean')
            validate_buffer_config(spec:get_config(), true, spec:get_path())
        end)
    end)

    validator:spec(config, false, 'custom_handlers'):for_each(false, function(spec)
        spec:type('extends', 'boolean'):type('parse', 'function')
    end)

    return validator:get_errors()
end

return M
