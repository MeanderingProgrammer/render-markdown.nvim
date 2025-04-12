local Compat = require('render-markdown.lib.compat')
local Config = require('render-markdown.config')
local Env = require('render-markdown.lib.env')
local log = require('render-markdown.core.log')
local presets = require('render-markdown.presets')
local ts = require('render-markdown.integ.ts')

---@type table<integer, render.md.BufferConfig>
local configs = {}

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field log_runtime boolean
---@field file_types string[]
---@field ignore fun(buf: integer): boolean
---@field change_events string[]
---@field patterns table<string, render.md.pattern.Config>
---@field on render.md.callback.Config
---@field completions render.md.completions.Config
---@field custom_handlers table<string, render.md.Handler>
local M = {}

---@param default render.md.Config
---@param user render.md.UserConfig
function M.setup(default, user)
    local preset = presets.get(user)
    local config = vim.tbl_deep_extend('force', default, preset, user)

    -- Override settings that require neovim >= 0.10.0 and have compatible alternatives
    if not Compat.has_10 then
        config.code.position = 'right'
    end

    -- Use lazy.nvim file type configuration if available and no user value is specified
    if user.file_types == nil then
        local lazy_file_types = Env.lazy('ft')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end

    M.config = config
    M.enabled = config.enabled
    M.log_runtime = config.log_runtime
    M.file_types = config.file_types
    M.ignore = config.ignore
    M.change_events = config.change_events
    M.patterns = config.patterns
    M.on = config.on
    M.completions = config.completions
    M.custom_handlers = config.custom_handlers
    log.setup(config.log_level)
    for _, language in ipairs(M.file_types) do
        ts.inject(language, config.injections[language])
    end

    M.invalidate_cache()
end

function M.invalidate_cache()
    configs = {}
end

---@param default render.md.Config
---@return table
function M.difference(default)
    return require('render-markdown.debug.diff').get(default, M.config)
end

---@param amount integer
function M.modify_anti_conceal(amount)
    ---@param anti_conceal render.md.anti.conceal.Config
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
---@return render.md.BufferConfig
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
---@return render.md.buffer.Config
function M.default_buffer_config()
    local config = M.config
    ---@type render.md.buffer.Config
    local buffer_config = {
        enabled = true,
        render_modes = config.render_modes,
        max_file_size = config.max_file_size,
        debounce = config.debounce,
        anti_conceal = config.anti_conceal,
        bullet = config.bullet,
        callout = config.callout,
        checkbox = config.checkbox,
        code = config.code,
        dash = config.dash,
        document = config.document,
        heading = config.heading,
        html = config.html,
        indent = config.indent,
        inline_highlight = config.inline_highlight,
        latex = config.latex,
        link = config.link,
        padding = config.padding,
        paragraph = config.paragraph,
        pipe_table = config.pipe_table,
        quote = config.quote,
        sign = config.sign,
        win_options = config.win_options,
    }
    return vim.deepcopy(buffer_config)
end

---@return string[]
function M.validate()
    local validator = require('render-markdown.debug.validator').new()
    local spec = validator:spec(M.config, false)
    Config.validate(spec)
    spec:one_of('preset', { 'none', 'lazy', 'obsidian' })
    spec:one_of('log_level', { 'off', 'debug', 'info', 'error' })
    spec:type('log_runtime', 'boolean')
    spec:list('file_types', 'string')
    spec:type('ignore', 'function')
    spec:list('change_events', 'string')
    spec:config('injections')
    spec:config('patterns')
    spec:config('on')
    spec:config('completions')
    spec:config('overrides')
    spec:nested('custom_handlers', function(handlers)
        handlers:each(function(handler)
            handler:type('extends', 'boolean')
            handler:type('parse', 'function')
            handler:check()
        end)
        handlers:check()
    end)
    spec:check()
    return validator:get_errors()
end

return M
