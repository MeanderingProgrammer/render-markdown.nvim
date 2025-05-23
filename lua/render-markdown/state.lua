local Config = require('render-markdown.lib.config')

---Used by LazyVim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/markdown.lua
---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
local M = {}

---@private
---@type table<integer, render.md.buf.Config>
M.cache = {}

---called from init on setup
---@param config render.md.Config
function M.setup(config)
    M.config = config
    M.enabled = config.enabled
    require('render-markdown.core.handlers').setup({
        custom = config.custom_handlers,
    })
    require('render-markdown.core.log').setup({
        level = config.log_level,
        runtime = config.log_runtime,
    })
    require('render-markdown.core.manager').setup({
        file_types = config.file_types,
        ignore = config.ignore,
        change_events = config.change_events,
        on = config.on,
        completions = config.completions,
    })
    require('render-markdown.core.ts').setup({
        file_types = config.file_types,
        injections = config.injections,
        patterns = config.patterns,
    })
    require('render-markdown.core.ui').setup({
        on = config.on,
    })
    require('render-markdown.integ.blink').setup({
        file_types = config.file_types,
    })
    require('render-markdown.integ.source').setup({
        completions = config.completions,
    })
    -- reset cache
    M.cache = {}
end

---@param buf integer
---@return render.md.buf.Config
function M.get(buf)
    local result = M.cache[buf]
    if not result then
        result = Config.new(M.config, M.enabled, buf)
        M.cache[buf] = result
    end
    return result
end

---@param amount integer
function M.modify_anti_conceal(amount)
    ---@param config render.md.anti.conceal.Config
    local function modify(config)
        config.above = math.max(config.above + amount, 0)
        config.below = math.max(config.below + amount, 0)
    end
    modify(M.config.anti_conceal)
    for _, config in pairs(M.cache) do
        modify(config.anti_conceal)
    end
end

---@return table?
function M.difference()
    local default = require('render-markdown').default
    return require('render-markdown.debug.diff').get(default, M.config)
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
    spec:nested('custom_handlers', require('render-markdown.config.handlers').validate)
    spec:check()
    return validator:get_errors()
end

return M
