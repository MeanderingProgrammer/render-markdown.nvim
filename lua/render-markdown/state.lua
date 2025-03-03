local Config = require('render-markdown.config')
local Env = require('render-markdown.lib.env')
local log = require('render-markdown.core.log')
local presets = require('render-markdown.presets')
local ts = require('render-markdown.integ.ts')

---@type table<integer, render.md.buffer.Config>
local configs = {}

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field log_runtime boolean
---@field file_types string[]
---@field change_events string[]
---@field patterns table<string, render.md.Pattern>
---@field on render.md.Callback
---@field completions render.md.Completions
---@field custom_handlers table<string, render.md.Handler>
local M = {}

---@return boolean
function M.initialized()
    return M.config ~= nil
end

---@param default_config render.md.Config
---@param user_config render.md.UserConfig
function M.setup(default_config, user_config)
    local preset_config = presets.get(user_config)
    local config = vim.tbl_deep_extend('force', default_config, preset_config, user_config)

    -- Override settings that require neovim >= 0.10.0 and have compatible alternatives
    if not Env.has_10 then
        config.code.position = 'right'
    end

    -- Use lazy.nvim file type configuration if available and no user value is specified
    if user_config.file_types == nil then
        local lazy_file_types = Env.lazy('ft')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end

    M.config = config
    M.enabled = config.enabled
    M.log_runtime = config.log_runtime
    M.file_types = config.file_types
    M.change_events = config.change_events
    M.patterns = config.patterns
    M.on = config.on
    M.completions = config.completions
    M.custom_handlers = config.custom_handlers
    log.setup(config.log_level)
    for _, language in ipairs(M.file_types) do
        ts.inject(language, config.injections[language])
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
        for _, name in ipairs({ 'buflisted', 'buftype', 'filetype' }) do
            local value = Env.buf.get(buf, name)
            local override = M.config.overrides[name][value]
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
        inline_highlight = config.inline_highlight,
        indent = config.indent,
        latex = config.latex,
        html = config.html,
        win_options = config.win_options,
    }
    return vim.deepcopy(buffer_config)
end

---@return string[]
function M.validate()
    ---@param component render.md.debug.ValidatorSpec
    ---@return render.md.debug.ValidatorSpec
    local function component_rules(component)
        return component:type('enabled', 'boolean'):list('render_modes', 'string', 'boolean')
    end

    ---@param buffer render.md.debug.ValidatorSpec
    ---@return render.md.debug.ValidatorSpec
    local function buffer_rules(buffer)
        return buffer
            :type('enabled', 'boolean')
            :type({ 'max_file_size', 'debounce' }, 'number')
            :list('render_modes', 'string', 'boolean')
            :nested('anti_conceal', function(anti_conceal)
                anti_conceal
                    :type('enabled', 'boolean')
                    :type({ 'above', 'below' }, 'number')
                    :nested('ignore', function(ignore)
                        ignore
                            :list({ 'head_icon', 'head_background', 'head_border' }, 'string', { 'boolean', 'nil' })
                            :list({ 'code_language', 'code_background', 'code_border' }, 'string', { 'boolean', 'nil' })
                            :list({ 'dash', 'bullet', 'check_icon', 'check_scope' }, 'string', { 'boolean', 'nil' })
                            :list({ 'quote', 'table_border', 'callout' }, 'string', { 'boolean', 'nil' })
                            :list({ 'link', 'sign' }, 'string', { 'boolean', 'nil' })
                            :check()
                    end)
                    :check()
            end)
            :nested('padding', function(padding)
                padding:type('highlight', 'string'):check()
            end)
            :nested('heading', function(heading)
                component_rules(heading)
                    :type({ 'sign', 'border_virtual', 'border_prefix' }, 'boolean')
                    :type({ 'above', 'below' }, 'string')
                    :list('border', 'boolean', 'boolean')
                    :list({ 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number', 'number')
                    :list({ 'signs', 'backgrounds', 'foregrounds' }, 'string')
                    :list('icons', 'string', 'function')
                    :one_of('position', { 'overlay', 'inline', 'right' })
                    :one_or_list_of('width', { 'full', 'block' })
                    :nested('custom', function(patterns)
                        patterns
                            :nested('ALL', function(pattern)
                                pattern
                                    :type('pattern', 'string')
                                    :type({ 'icon', 'background', 'foreground' }, { 'string', 'nil' })
                                    :check()
                            end, false)
                            :check()
                    end)
                    :check()
            end)
            :nested('paragraph', function(paragraph)
                component_rules(paragraph):type({ 'left_margin', 'min_width' }, 'number'):check()
            end)
            :nested('code', function(code)
                component_rules(code)
                    :type({ 'sign', 'language_icon', 'language_name' }, 'boolean')
                    :type({ 'language_pad', 'left_margin', 'left_pad', 'right_pad', 'min_width' }, 'number')
                    :type('inline_pad', 'number')
                    :type({ 'above', 'below', 'highlight', 'highlight_fallback', 'highlight_inline' }, 'string')
                    :type('highlight_language', { 'string', 'nil' })
                    :list('disable_background', 'string', 'boolean')
                    :one_of('style', { 'full', 'normal', 'language', 'none' })
                    :one_of('position', { 'left', 'right' })
                    :one_of('width', { 'full', 'block' })
                    :one_of('border', { 'hide', 'thin', 'thick', 'none' })
                    :check()
            end)
            :nested('dash', function(dash)
                component_rules(dash)
                    :type('left_margin', 'number')
                    :type({ 'icon', 'highlight' }, 'string')
                    :one_of('width', { 'full' }, 'number')
                    :check()
            end)
            :nested('bullet', function(bullet)
                component_rules(bullet)
                    :type({ 'left_pad', 'right_pad' }, { 'number', 'function' })
                    :nested_list({ 'icons', 'ordered_icons', 'highlight', 'scope_highlight' }, 'string', 'function')
                    :check()
            end)
            :nested('checkbox', function(checkbox)
                component_rules(checkbox)
                    :type('right_pad', 'number')
                    :nested({ 'unchecked', 'checked' }, function(box)
                        box:type({ 'icon', 'highlight' }, 'string'):type('scope_highlight', { 'string', 'nil' }):check()
                    end)
                    :nested('custom', function(boxes)
                        boxes:nested('ALL', function(box)
                            box:type({ 'raw', 'rendered', 'highlight' }, 'string')
                                :type('scope_highlight', { 'string', 'nil' })
                                :check()
                        end)
                    end)
                    :check()
            end)
            :nested('quote', function(quote)
                component_rules(quote)
                    :type('repeat_linebreak', 'boolean')
                    :type({ 'icon', 'highlight' }, 'string')
                    :check()
            end)
            :nested('pipe_table', function(pipe_table)
                component_rules(pipe_table)
                    :type({ 'padding', 'min_width' }, 'number')
                    :type({ 'alignment_indicator', 'head', 'row', 'filler' }, 'string')
                    :list('border', 'string')
                    :one_of('preset', { 'none', 'round', 'double', 'heavy' })
                    :one_of('style', { 'full', 'normal', 'none' })
                    :one_of('cell', { 'trimmed', 'padded', 'raw', 'overlay' })
                    :check()
            end)
            :nested('callout', function(callouts)
                callouts
                    :nested('ALL', function(callout)
                        callout
                            :type({ 'raw', 'rendered', 'highlight' }, 'string')
                            :type({ 'quote_icon', 'category' }, { 'string', 'nil' })
                            :check()
                    end, false)
                    :check()
            end)
            :nested('link', function(link)
                component_rules(link)
                    :type({ 'image', 'email', 'hyperlink', 'highlight' }, 'string')
                    :nested('footnote', function(footnote)
                        footnote
                            :type({ 'enabled', 'superscript' }, 'boolean')
                            :type({ 'prefix', 'suffix' }, 'string')
                            :check()
                    end)
                    :nested('wiki', function(wiki)
                        wiki:type({ 'icon', 'highlight' }, 'string'):type('body', 'function'):check()
                    end)
                    :nested('custom', function(patterns)
                        patterns
                            :nested('ALL', function(pattern)
                                pattern
                                    :type({ 'pattern', 'icon' }, 'string')
                                    :type('highlight', { 'string', 'nil' })
                                    :check()
                            end, false)
                            :check()
                    end)
                    :check()
            end)
            :nested('sign', function(sign)
                sign:type('enabled', 'boolean'):type('highlight', 'string'):check()
            end)
            :nested('inline_highlight', function(inline_highlight)
                component_rules(inline_highlight):type('highlight', 'string'):check()
            end)
            :nested('indent', function(indent)
                component_rules(indent)
                    :type('skip_heading', 'boolean')
                    :type({ 'per_level', 'skip_level' }, 'number')
                    :type({ 'icon', 'highlight' }, 'string')
                    :check()
            end)
            :nested('latex', function(latex)
                component_rules(latex)
                    :type({ 'top_pad', 'bottom_pad' }, 'number')
                    :type({ 'converter', 'highlight' }, 'string')
                    :one_of('position', { 'above', 'below' })
                    :check()
            end)
            :nested('html', function(html)
                component_rules(html)
                    :nested('comment', function(comment)
                        comment
                            :type('conceal', 'boolean')
                            :type('highlight', 'string')
                            :type('text', { 'string', 'nil' })
                            :check()
                    end)
                    :nested('tag', function(tags)
                        tags:nested('ALL', function(tag)
                            tag:type({ 'icon', 'highlight' }, 'string'):check()
                        end, false):check()
                    end)
                    :check()
            end)
            :nested('win_options', function(win_options)
                win_options
                    :nested('ALL', function(win_option)
                        win_option:type({ 'default', 'rendered' }, { 'number', 'string', 'boolean' }):check()
                    end, false)
                    :check()
            end)
    end

    local validator = require('render-markdown.debug.validator').new()

    buffer_rules(validator:spec(M.config, false))
        :type('log_runtime', 'boolean')
        :list({ 'file_types', 'change_events' }, 'string')
        :one_of('preset', { 'none', 'lazy', 'obsidian' })
        :one_of('log_level', { 'off', 'debug', 'info', 'error' })
        :nested('injections', function(injections)
            injections
                :nested('ALL', function(injection)
                    injection:type('enabled', 'boolean'):type('query', 'string'):check()
                end)
                :check()
        end)
        :nested('patterns', function(patterns)
            patterns
                :nested('ALL', function(pattern)
                    pattern
                        :type('disable', 'boolean')
                        :nested('directives', function(directives)
                            directives:nested('ALL', function(directive)
                                directive:type('id', 'number'):type('name', 'string'):check()
                            end)
                        end)
                        :check()
                end)
                :check()
        end)
        :nested('on', function(on)
            on:type({ 'attach', 'render', 'clear' }, 'function'):check()
        end)
        :nested('completions', function(completions)
            completions
                :nested('blink', function(coq)
                    coq:type('enabled', 'boolean'):check()
                end)
                :nested('coq', function(coq)
                    coq:type('enabled', 'boolean'):check()
                end)
                :nested('lsp', function(lsp)
                    lsp:type('enabled', 'boolean'):check()
                end)
                :nested('filter', function(filter)
                    filter:type({ 'callout', 'checkbox' }, 'function'):check()
                end)
                :check()
        end)
        :nested('overrides', function(overrides)
            overrides
                :nested({ 'buflisted', 'buftype', 'filetype' }, function(override)
                    override
                        :nested('ALL', function(buffer)
                            buffer_rules(buffer):check()
                        end, true)
                        :check()
                end)
                :check()
        end)
        :nested('custom_handlers', function(custom_handlers)
            custom_handlers
                :nested('ALL', function(spec)
                    spec:type('extends', 'boolean'):type('parse', 'function'):check()
                end)
                :check()
        end)
        :check()

    return validator:get_errors()
end

return M
