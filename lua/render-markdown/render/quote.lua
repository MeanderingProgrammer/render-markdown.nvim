local component = require('render-markdown.core.component')
local logger = require('render-markdown.core.logger')
local state = require('render-markdown.state')

---@class render.md.render.Quote: render.md.Renderer
---@field private quote render.md.Quote
local Render = {}
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render.new(marks, config, context, info)
    return setmetatable({ marks = marks, config = config, context = context, info = info }, Render)
end

---@return boolean
function Render:setup()
    self.quote = self.config.quote
    if not self.quote.enabled then
        return false
    end

    return true
end

function Render:render()
    self.context:query(self.info.node, state.markdown_quote_query, function(capture, info)
        if capture == 'quote_marker' then
            self:quote_marker(info)
        else
            logger.unhandled_capture('markdown quote', capture)
        end
    end)
end

---@private
---@param info render.md.NodeInfo
function Render:quote_marker(info)
    local callout = component.callout(self.config, self.info.text, 'contains')
    local highlight = callout ~= nil and callout.highlight or self.quote.highlight
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { info.text:gsub('>', self.quote.icon), highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = self.quote.repeat_linebreak or nil,
    })
end

return Render
