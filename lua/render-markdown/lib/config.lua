local Env = require('render-markdown.lib.env')
local Iter = require('render-markdown.lib.iter')
local Line = require('render-markdown.lib.line')
local Resolved = require('render-markdown.lib.resolved')

---@class render.md.buf.Config: render.md.partial.Config
---@field resolved render.md.resolved.Config
local Config = {}
Config.__index = Config

---@param root render.md.Config
---@param enabled boolean
---@param buf integer
---@return render.md.buf.Config
function Config.new(root, enabled, buf)
    ---@type render.md.partial.Config
    local config = {
        enabled = enabled,
        render_modes = root.render_modes,
        max_file_size = root.max_file_size,
        debounce = root.debounce,
        anti_conceal = root.anti_conceal,
        bullet = root.bullet,
        callout = root.callout,
        checkbox = root.checkbox,
        code = root.code,
        dash = root.dash,
        document = root.document,
        heading = root.heading,
        html = root.html,
        indent = root.indent,
        inline_highlight = root.inline_highlight,
        latex = root.latex,
        link = root.link,
        padding = root.padding,
        paragraph = root.paragraph,
        pipe_table = root.pipe_table,
        quote = root.quote,
        sign = root.sign,
        win_options = root.win_options,
    }
    config = vim.deepcopy(config)
    for _, name in ipairs({ 'buflisted', 'buftype', 'filetype' }) do
        local value = Env.buf.get(buf, name)
        local override = root.overrides[name][value]
        if override then
            config = vim.tbl_deep_extend('force', config, override)
        end
    end
    local self = setmetatable(config, Config)
    self.resolved = Resolved.new(config)
    ---@cast self -render.md.partial.Config
    return self
end

---@return render.md.Line
function Config:line()
    return Line.new(self)
end

---@param destination string
---@param icon render.md.mark.Text
function Config:set_link_text(destination, icon)
    local options = Iter.table.filter(self.link.custom, function(custom)
        if custom.kind == 'suffix' then
            return vim.endswith(destination, custom.pattern)
        else
            return destination:find(custom.pattern) ~= nil
        end
    end)
    Iter.list.sort(options, function(custom)
        return custom.priority or #custom.pattern
    end)
    local result = options[#options]
    if result then
        icon[1] = result.icon
        icon[2] = result.highlight or icon[2]
    end
end

-- stylua: ignore
---@param spec render.md.debug.ValidatorSpec
function Config.validate(spec)
    local Base = require('render-markdown.config.base')
    Base.validate(spec)
    spec:type('max_file_size', 'number')
    spec:type('debounce', 'number')
    spec:nested('anti_conceal', require('render-markdown.config.anti_conceal').validate)
    spec:nested('bullet', require('render-markdown.config.bullet').validate)
    spec:nested('callout', require('render-markdown.config.callout').validate)
    spec:nested('checkbox', require('render-markdown.config.checkbox').validate)
    spec:nested('code', require('render-markdown.config.code').validate)
    spec:nested('dash', require('render-markdown.config.dash').validate)
    spec:nested('document', require('render-markdown.config.document').validate)
    spec:nested('heading', require('render-markdown.config.heading').validate)
    spec:nested('html', require('render-markdown.config.html').validate)
    spec:nested('indent', require('render-markdown.config.indent').validate)
    spec:nested('inline_highlight', require('render-markdown.config.inline_highlight').validate)
    spec:nested('latex', require('render-markdown.config.latex').validate)
    spec:nested('link', require('render-markdown.config.link').validate)
    spec:nested('padding', require('render-markdown.config.padding').validate)
    spec:nested('paragraph', require('render-markdown.config.paragraph').validate)
    spec:nested('pipe_table', require('render-markdown.config.pipe_table').validate)
    spec:nested('quote', require('render-markdown.config.quote').validate)
    spec:nested('sign', require('render-markdown.config.sign').validate)
    spec:nested('win_options', require('render-markdown.config.win_options').validate)
end

return Config
