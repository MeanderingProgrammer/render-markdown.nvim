---@class render.md.Init: render.md.Api
local M = {}

---@class (exact) render.md.Config: render.md.partial.Config
---@field preset render.md.config.Preset
---@field log_level render.md.log.Level
---@field log_runtime boolean
---@field file_types string[]
---@field ignore fun(buf: integer): boolean
---@field change_events string[]
---@field injections render.md.injection.Configs
---@field patterns render.md.pattern.Configs
---@field on render.md.on.Config
---@field completions render.md.completions.Config
---@field overrides render.md.overrides.Config
---@field custom_handlers table<string, render.md.Handler>

---@class (exact) render.md.partial.Config: render.md.base.Config
---@field max_file_size number
---@field debounce integer
---@field anti_conceal render.md.anti.conceal.Config
---@field bullet render.md.bullet.Config
---@field callout render.md.callout.Configs
---@field checkbox render.md.checkbox.Config
---@field code render.md.code.Config
---@field dash render.md.dash.Config
---@field document render.md.document.Config
---@field heading render.md.heading.Config
---@field html render.md.html.Config
---@field indent render.md.indent.Config
---@field inline_highlight render.md.inline.highlight.Config
---@field latex render.md.latex.Config
---@field link render.md.link.Config
---@field padding render.md.padding.Config
---@field paragraph render.md.paragraph.Config
---@field pipe_table render.md.table.Config
---@field quote render.md.quote.Config
---@field sign render.md.sign.Config
---@field win_options render.md.window.Configs

---@private
---@type boolean
M.initialized = false

---@type render.md.Config
M.default = {
    -- Whether markdown should be rendered by default.
    enabled = true,
    -- Vim modes that will show a rendered view of the markdown file, :h mode(), for all enabled
    -- components. Individual components can be enabled for other modes. Remaining modes will be
    -- unaffected by this plugin.
    render_modes = { 'n', 'c', 't' },
    -- Maximum file size (in MB) that this plugin will attempt to render.
    -- File larger than this will effectively be ignored.
    max_file_size = 10.0,
    -- Milliseconds that must pass before updating marks, updates occur.
    -- within the context of the visible window, not the entire buffer.
    debounce = 100,
    -- Pre configured settings that will attempt to mimic various target user experiences.
    -- User provided settings will take precedence.
    -- | obsidian | mimic Obsidian UI                                          |
    -- | lazy     | will attempt to stay up to date with LazyVim configuration |
    -- | none     | does nothing                                               |
    preset = 'none',
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'.
    -- Only intended to be used for plugin development / debugging.
    log_level = 'error',
    -- Print runtime of main update method.
    -- Only intended to be used for plugin development / debugging.
    log_runtime = false,
    -- Filetypes this plugin will run on.
    file_types = { 'markdown' },
    -- Takes buffer as input, if it returns true this plugin will not attach to the buffer
    ignore = function()
        return false
    end,
    -- Additional events that will trigger this plugin's render loop.
    change_events = {},
    injections = require('render-markdown.config.injections').default,
    patterns = require('render-markdown.config.patterns').default,
    anti_conceal = require('render-markdown.config.anti_conceal').default,
    padding = require('render-markdown.config.padding').default,
    latex = require('render-markdown.config.latex').default,
    on = require('render-markdown.config.on').default,
    completions = require('render-markdown.config.completions').default,
    heading = require('render-markdown.config.heading').default,
    paragraph = require('render-markdown.config.paragraph').default,
    code = require('render-markdown.config.code').default,
    dash = require('render-markdown.config.dash').default,
    document = require('render-markdown.config.document').default,
    bullet = require('render-markdown.config.bullet').default,
    checkbox = require('render-markdown.config.checkbox').default,
    quote = require('render-markdown.config.quote').default,
    pipe_table = require('render-markdown.config.pipe_table').default,
    callout = require('render-markdown.config.callout').default,
    link = require('render-markdown.config.link').default,
    sign = require('render-markdown.config.sign').default,
    inline_highlight = require('render-markdown.config.inline_highlight').default,
    indent = require('render-markdown.config.indent').default,
    html = require('render-markdown.config.html').default,
    win_options = require('render-markdown.config.win_options').default,
    overrides = require('render-markdown.config.overrides').default,
    custom_handlers = require('render-markdown.config.handlers').default,
}

---@param opts? render.md.UserConfig
function M.setup(opts)
    -- This handles discrepancies in initialization order of different plugin managers, some
    -- run the plugin directory first (lazy.nvim) while others run setup first (vim-plug).
    -- To support both we want to pickup the last non-empty configuration. This works because
    -- the plugin directory supplies an empty configuration which will be skipped if state
    -- has already been initialized by the user.
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true
    local config = M.resolve_config(opts or {})
    require('render-markdown.state').setup(config)
end

---@private
---@param user render.md.UserConfig
---@return render.md.Config
function M.resolve_config(user)
    local preset = require('render-markdown.lib.presets').get(user)
    local config = vim.tbl_deep_extend('force', M.default, preset, user)
    -- section indentation is built to support headings
    if config.indent.enabled then
        config.pipe_table.border_virtual = true
    end
    -- override settings incompatible with neovim version with compatible alternatives
    local compat = require('render-markdown.lib.compat')
    if config.code.border == 'hide' and not compat.has_11 then
        config.code.border = 'thin'
    end
    -- use lazy.nvim file type configuration if available and no user value is specified
    if not user.file_types then
        local lazy_file_types = require('render-markdown.lib.env').lazy('ft')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end
    return config
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('render-markdown.api')[key]
    end,
})
