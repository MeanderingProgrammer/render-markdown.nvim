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
    -- Use lazy.nvim file type configuration if available and no user value is specified
    if user_config.file_types == nil then
        local lazy_file_types = util.lazy_file_types('render-markdown.nvim')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
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

    ---@param path string
    ---@param config render.md.BufferConfig|render.md.UserBufferConfig
    ---@param nilable boolean
    local function validate_buffer_config(path, config, nilable)
        validator
            :spec(path, config, 'anti_conceal', nilable)
            :type('enabled', 'boolean')
            :type({ 'above', 'below' }, 'number')
            :check()

        validator:spec(path, config, 'padding', nilable):type('highlight', 'string'):check()

        validator
            :spec(path, config, 'heading', nilable)
            :type({ 'enabled', 'sign', 'border', 'border_virtual', 'border_prefix' }, 'boolean')
            :type({ 'above', 'below' }, 'string')
            :array({ 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number', 'number')
            :array({ 'icons', 'signs', 'backgrounds', 'foregrounds' }, 'string')
            :one_of('position', { 'overlay', 'inline' })
            :one_or_array_of('width', { 'full', 'block' })
            :check()

        validator
            :spec(path, config, 'code', nilable)
            :type({ 'enabled', 'sign' }, 'boolean')
            :type({ 'language_pad', 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number')
            :type({ 'above', 'below', 'highlight', 'highlight_inline' }, 'string')
            :array('disable_background', 'string')
            :one_of('style', { 'full', 'normal', 'language', 'none' })
            :one_of('position', { 'left', 'right' })
            :one_of('width', { 'full', 'block' })
            :one_of('border', { 'thin', 'thick' })
            :check()

        validator
            :spec(path, config, 'dash', nilable)
            :type('enabled', 'boolean')
            :type({ 'icon', 'highlight' }, 'string')
            :one_of('width', { 'full' }, 'number')
            :check()

        validator
            :spec(path, config, 'bullet', nilable)
            :type('enabled', 'boolean')
            :type({ 'left_pad', 'right_pad' }, 'number')
            :type('highlight', 'string')
            :array('icons', 'string')
            :check()

        validator
            :spec(path, config, 'checkbox', nilable)
            :type('enabled', 'boolean')
            :type({ 'unchecked', 'checked', 'custom' }, 'table')
            :one_of('position', { 'overlay', 'inline' })
            :check()
        validator
            :spec(path, config, { 'checkbox', 'unchecked' }, nilable)
            :type({ 'icon', 'highlight' }, 'string')
            :check()
        validator:spec(path, config, { 'checkbox', 'checked' }, nilable):type({ 'icon', 'highlight' }, 'string'):check()
        validator:spec(path, config, { 'checkbox', 'custom' }, nilable):for_each(function(spec)
            spec:type({ 'raw', 'rendered', 'highlight' }, 'string'):check()
        end)

        validator
            :spec(path, config, 'quote', nilable)
            :type({ 'enabled', 'repeat_linebreak' }, 'boolean')
            :type({ 'icon', 'highlight' }, 'string')
            :check()

        validator
            :spec(path, config, 'pipe_table', nilable)
            :type('enabled', 'boolean')
            :type('min_width', 'number')
            :type({ 'alignment_indicator', 'head', 'row', 'filler' }, 'string')
            :array('border', 'string')
            :one_of('preset', { 'none', 'round', 'double', 'heavy' })
            :one_of('style', { 'full', 'normal', 'none' })
            :one_of('cell', { 'trimmed', 'padded', 'raw', 'overlay' })
            :check()

        validator:spec(path, config, 'callout', nilable):for_each(function(spec)
            spec:type({ 'raw', 'rendered', 'highlight' }, 'string'):check()
        end)

        validator
            :spec(path, config, 'link', nilable)
            :type('enabled', 'boolean')
            :type({ 'image', 'email', 'hyperlink', 'highlight' }, 'string')
            :type('custom', 'table')
            :check()
        validator:spec(path, config, { 'link', 'custom' }, nilable):for_each(function(spec)
            spec:type({ 'pattern', 'icon', 'highlight' }, 'string'):check()
        end)

        validator:spec(path, config, 'sign', nilable):type('enabled', 'boolean'):type('highlight', 'string'):check()

        validator
            :spec(path, config, 'indent', nilable)
            :type({ 'enabled', 'skip_heading' }, 'boolean')
            :type({ 'per_level', 'skip_level' }, 'number')
            :check()

        validator:spec(path, config, 'win_options', nilable):for_each(function(spec)
            spec:type({ 'default', 'rendered' }, { 'number', 'string', 'boolean' }):check()
        end)
    end

    local config = M.config
    validator
        :spec('', config)
        :type('enabled', 'boolean')
        :type({ 'max_file_size', 'debounce' }, 'number')
        :type({ 'anti_conceal', 'padding', 'heading', 'code', 'dash', 'bullet', 'checkbox' }, 'table')
        :type({ 'quote', 'pipe_table', 'callout', 'link', 'sign', 'indent', 'win_options' }, 'table')
        :array('render_modes', 'string', 'boolean')
        :type({ 'markdown_query', 'markdown_quote_query', 'inline_query' }, 'string')
        :type({ 'injections', 'latex', 'overrides', 'custom_handlers' }, 'table')
        :array('file_types', 'string')
        :one_of('preset', { 'none', 'lazy', 'obsidian' })
        :one_of('log_level', { 'debug', 'info', 'error' })
        :check()

    validate_buffer_config('', config, false)

    validator:spec('', config, 'injections'):for_each(function(spec)
        spec:type('enabled', 'boolean'):type('query', 'string'):check()
    end)

    validator
        :spec('', config, 'latex')
        :type('enabled', 'boolean')
        :type({ 'top_pad', 'bottom_pad' }, 'number')
        :type({ 'converter', 'highlight' }, 'string')
        :check()

    validator:spec('', config, 'overrides'):type({ 'buftype', 'filetype' }, 'table'):check()

    validator:spec('', config, 'overrides'):for_each(function(override_spec)
        override_spec:for_each(function(spec)
            spec:type('enabled', 'boolean')
                :type({ 'max_file_size', 'debounce' }, 'number')
                :type({ 'anti_conceal', 'padding', 'heading', 'code', 'dash', 'bullet', 'checkbox' }, 'table')
                :type({ 'quote', 'pipe_table', 'callout', 'link', 'sign', 'indent', 'win_options' }, 'table')
                :array('render_modes', 'string', 'boolean')
                :check()
            validate_buffer_config(spec:get_suffix(), spec:get_input(), true)
        end, true)
    end)

    validator:spec('', config, 'custom_handlers'):for_each(function(spec)
        spec:type('extends', 'boolean'):type('parse', 'function'):check()
    end)

    return validator:get_errors()
end

return M
