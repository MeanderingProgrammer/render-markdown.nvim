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
        nested = config.nested,
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
        restart_highlighter = config.restart_highlighter,
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

---@return string[]
function M.validate()
    return require('render-markdown.debug.schema').validate(
        M.config,
        Config.schema({
            preset = { enum = { 'none', 'lazy', 'obsidian' } },
            log_level = {
                enum = { 'trace', 'debug', 'info', 'warn', 'error', 'off' },
            },
            log_runtime = { type = 'boolean' },
            file_types = { list = { type = 'string' } },
            ignore = { type = 'function' },
            nested = { type = 'boolean' },
            change_events = { list = { type = 'string' } },
            restart_highlighter = { type = 'boolean' },
            injections = require('render-markdown.config.injections').schema(),
            patterns = require('render-markdown.config.patterns').schema(),
            on = require('render-markdown.config.on').schema(),
            completions = require('render-markdown.config.completions').schema(),
            overrides = require('render-markdown.config.overrides').schema(),
            custom_handlers = require('render-markdown.config.handlers').schema(),
        })
    )
end

return M
