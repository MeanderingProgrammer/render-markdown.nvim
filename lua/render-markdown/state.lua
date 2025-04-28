local Config = require('render-markdown.config')
local Env = require('render-markdown.lib.env')

---@class render.md.state.Cache: { [integer]: render.md.main.Config }
local Cache = {}

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field file_types string[]
local M = {}

---called from init on setup
---@param config render.md.Config
function M.setup(config)
    M.config = config
    M.enabled = config.enabled
    M.file_types = config.file_types
    require('render-markdown.manager').setup({
        ignore = config.ignore,
        change_events = config.change_events,
        on = config.on,
        completions = config.completions,
    })
    require('render-markdown.core.log').setup({
        level = config.log_level,
        runtime = config.log_runtime,
    })
    require('render-markdown.core.ui').setup({
        on = config.on,
        custom_handlers = config.custom_handlers,
    })
    require('render-markdown.integ.source').setup({
        completions = config.completions,
    })
    require('render-markdown.integ.ts').setup({
        file_types = config.file_types,
        injections = config.injections,
        patterns = config.patterns,
    })
    M.invalidate_cache()
end

---@private
function M.invalidate_cache()
    Cache = {}
end

---@return table?
function M.difference()
    local default = require('render-markdown').default
    return require('render-markdown.debug.diff').get(default, M.config)
end

---@param amount integer
function M.modify_anti_conceal(amount)
    ---@param config render.md.anti.conceal.Config
    local function modify(config)
        config.above = math.max(config.above + amount, 0)
        config.below = math.max(config.below + amount, 0)
    end
    modify(M.config.anti_conceal)
    for _, config in pairs(Cache) do
        modify(config.anti_conceal)
    end
end

---@param buf integer
---@return render.md.main.Config
function M.get(buf)
    local result = Cache[buf]
    if result == nil then
        local config = M.default_buffer_config()
        for _, name in ipairs({ 'buflisted', 'buftype', 'filetype' }) do
            local value = Env.buf.get(buf, name)
            local override = M.config.overrides[name][value]
            if override ~= nil then
                config = vim.tbl_deep_extend('force', config, override)
            end
        end
        result = Config.new(config)
        Cache[buf] = result
    end
    return result
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

-- stylua: ignore
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
    spec:nested('injections', require('render-markdown.config.injections').validate)
    spec:nested('patterns', require('render-markdown.config.patterns').validate)
    spec:nested('on', require('render-markdown.config.on').validate)
    spec:nested('completions', require('render-markdown.config.completions').validate)
    spec:nested('overrides', require('render-markdown.config.overrides').validate)
    spec:nested('custom_handlers', require('render-markdown.config.custom_handlers').validate)
    spec:check()
    return validator:get_errors()
end

return M
