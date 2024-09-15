local Base = require('render-markdown.render.base')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

---@class render.md.render.Quote: render.md.Renderer
---@field private quote render.md.Quote
---@field private highlight string
local Render = setmetatable({}, Base)
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render:new(marks, config, context, info)
    return Base.new(self, marks, config, context, info)
end

---@return boolean
function Render:setup()
    self.quote = self.config.quote
    if not self.quote.enabled then
        return false
    end

    local callout = self.context:get_component(self.info)
    self.highlight = callout ~= nil and callout.highlight or self.quote.highlight

    return true
end

function Render:render()
    self.context:query(self.info.node, state.markdown_quote_query, function(capture, info)
        if capture == 'quote_marker' then
            self:quote_marker(info)
        else
            log.unhandled_capture('markdown quote', capture)
        end
    end)
end

---@private
---@param info render.md.NodeInfo
function Render:quote_marker(info)
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { info.text:gsub('>', self.quote.icon), self.highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = self.quote.repeat_linebreak or nil,
    })
end

return Render
