local Config = require('render-markdown.lib.config')

---@class render.md.State
---@field private config render.md.Config
---@field enabled boolean
---@field log_level render.md.log.Level
---@field log_runtime boolean
---@field file_types string[]
---@field max_file_size number
---@field ignore fun(buf: integer): boolean
---@field nested boolean
---@field change_events string[]
---@field restart_highlighter boolean
---@field injections table<string, render.md.injection.Config>
---@field patterns table<string, render.md.pattern.Config>
---@field on render.md.on.Config
---@field completions render.md.completions.Config
---@field custom_handlers table<string, render.md.Handler>
local M = {}

---@private
---@type table<integer, render.md.buf.Config>
M.cache = {}

---called from init on setup
---@param config render.md.Config
function M.setup(config)
    M.config = config
    M.enabled = config.enabled
    M.log_level = config.log_level
    M.log_runtime = config.log_runtime
    M.file_types = config.file_types
    M.max_file_size = config.max_file_size
    M.ignore = config.ignore
    M.nested = config.nested
    M.change_events = config.change_events
    M.restart_highlighter = config.restart_highlighter
    M.injections = config.injections
    M.patterns = config.patterns
    M.on = config.on
    M.completions = config.completions
    M.custom_handlers = config.custom_handlers

    -- reset cache
    M.cache = {}

    require('render-markdown.core.ts').setup()
    require('render-markdown.core.ui').setup()
end

---@param buf integer
---@param custom? render.md.partial.UserConfig
---@return render.md.buf.Config
function M.get(buf, custom)
    if not M.cache[buf] then
        M.cache[buf] = Config.new(M.config, M.enabled, buf, custom)
    end
    return assert(M.cache[buf], 'missing buffer config')
end

function M.attach()
    require('render-markdown.core.ts').init()
    if M.completions.lsp.enabled then
        require('render-markdown.integ.lsp').init()
    elseif M.completions.blink.enabled then
        require('render-markdown.integ.blink').init()
    elseif M.completions.coq.enabled then
        require('render-markdown.integ.coq').init()
    else
        require('render-markdown.integ.cmp').init()
    end
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
    local settings = require('render-markdown.settings')
    return require('render-markdown.debug.schema').validate(
        M.config,
        Config.schema({
            preset = { enum = { 'none', 'lazy', 'obsidian' } },
            log_level = {
                enum = { 'trace', 'debug', 'info', 'warn', 'error', 'off' },
            },
            log_runtime = { type = 'boolean' },
            file_types = { list = { type = 'string' } },
            max_file_size = { type = 'number' },
            ignore = { type = 'function' },
            nested = { type = 'boolean' },
            change_events = { list = { type = 'string' } },
            restart_highlighter = { type = 'boolean' },
            injections = settings.injections.schema(),
            patterns = settings.patterns.schema(),
            on = settings.on.schema(),
            completions = settings.completions.schema(),
            overrides = settings.overrides.schema(),
            custom_handlers = settings.handlers.schema(),
        })
    )
end

return M
