local Base = require('render-markdown.render.base')
local list = require('render-markdown.lib.list')

---@class render.md.yaml.bullet.Data
---@field icon? string
---@field highlight? string

---@class render.md.render.yaml.Bullet: render.md.Render
---@field private config render.md.bullet.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.bullet
    if not self.config.enabled then
        return false
    end
    return true
end

---@protected
function Render:run()
    ---@type render.md.bullet.Context
    local ctx = {
        level = self.node:level_in('block_sequence', 'document'),
        index = self.node:sibling_count('block_sequence_item'),
        value = '-',
    }
    local icon = Render.get_string(self.config.icons, ctx)
    local highlight = Render.get_string(self.config.highlight, ctx)
    if not icon or not highlight then
        return
    end
    self.marks:start(self.config, 'bullet', self.node, {
        virt_text = { { icon, highlight } },
        virt_text_pos = 'overlay',
    })
end

---@private
---@param values render.md.bullet.String
---@param ctx render.md.bullet.Context
---@return string?
function Render.get_string(values, ctx)
    if type(values) == 'table' then
        local value = list.cycle(values, ctx.level)
        if type(value) == 'table' then
            return list.clamp(value, ctx.index)
        else
            return value
        end
    elseif type(values) == 'function' then
        return values(ctx)
    else
        return values
    end
end

return Render
