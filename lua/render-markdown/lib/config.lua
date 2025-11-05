local Line = require('render-markdown.lib.line')
local Resolved = require('render-markdown.lib.resolved')
local env = require('render-markdown.lib.env')
local iter = require('render-markdown.lib.iter')

---@class render.md.buf.Config: render.md.partial.Config
---@field resolved render.md.resolved.Config
local Config = {}
Config.__index = Config

---@param root render.md.Config
---@param enabled boolean
---@param buf integer
---@param custom? render.md.partial.UserConfig
---@return render.md.buf.Config
function Config.new(root, enabled, buf, custom)
    ---@type render.md.partial.Config
    local config = {
        enabled = enabled,
        render_modes = root.render_modes,
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
        yaml = root.yaml,
    }
    config = vim.deepcopy(config)

    ---@param override? render.md.partial.UserConfig
    local function extend(override)
        config = vim.tbl_deep_extend('force', config, override or {})
    end

    local src = require('render-markdown.core.preview').get(buf)
    extend(root.overrides.buflisted[env.buf.get(src or buf, 'buflisted')])
    extend(root.overrides.buftype[env.buf.get(src or buf, 'buftype')])
    extend(root.overrides.filetype[env.buf.get(src or buf, 'filetype')])
    extend(src and root.overrides.preview)
    extend(custom)

    local self = setmetatable(config, Config)
    self.resolved = Resolved.new(config)
    ---@cast self -render.md.partial.Config
    return self
end

---@return render.md.Line
function Config:line()
    return Line.new(self.padding.highlight)
end

---@param destination string
---@param icon render.md.mark.Text
function Config:set_link_text(destination, icon)
    local options = iter.table.filter(self.link.custom, function(custom)
        if custom.kind == 'suffix' then
            return vim.endswith(destination, custom.pattern)
        else
            return destination:find(custom.pattern) ~= nil
        end
    end)
    iter.list.sort(options, function(custom)
        return custom.priority or #custom.pattern
    end)
    local result = options[#options]
    if result then
        icon[1] = result.icon
        icon[2] = result.highlight or icon[2]
    end
end

---@param child render.md.schema.Record
---@return render.md.Schema
function Config.schema(child)
    local settings = require('render-markdown.settings')
    ---@type render.md.schema.Record
    local parent = {
        debounce = { type = 'number' },
        anti_conceal = settings.anti_conceal.schema(),
        bullet = settings.bullet.schema(),
        callout = settings.callout.schema(),
        checkbox = settings.checkbox.schema(),
        code = settings.code.schema(),
        dash = settings.dash.schema(),
        document = settings.document.schema(),
        heading = settings.heading.schema(),
        html = settings.html.schema(),
        indent = settings.indent.schema(),
        inline_highlight = settings.inline_highlight.schema(),
        latex = settings.latex.schema(),
        link = settings.link.schema(),
        padding = settings.padding.schema(),
        paragraph = settings.paragraph.schema(),
        pipe_table = settings.pipe_table.schema(),
        quote = settings.quote.schema(),
        sign = settings.sign.schema(),
        win_options = settings.win_options.schema(),
        yaml = settings.yaml.schema(),
    }
    local record = vim.tbl_deep_extend('error', parent, child)
    return settings.base.schema(record)
end

return Config
