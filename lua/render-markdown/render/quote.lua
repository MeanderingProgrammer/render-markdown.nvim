local NodeInfo = require('render-markdown.core.node_info')
local component = require('render-markdown.core.component')
local logger = require('render-markdown.core.logger')
local state = require('render-markdown.state')

---@class render.md.render.Quote: render.md.Renderer
---@field private config render.md.Quote
local Render = {}
Render.__index = Render

---@param buf integer
---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@return render.md.render.Quote
function Render.new(buf, marks, config, context)
    local self = setmetatable({}, Render)
    self.buf = buf
    self.marks = marks
    self.config = config.quote
    self.context = context
    return self
end

---@param info render.md.NodeInfo
function Render:render(info)
    self.context:query(info.node, state.markdown_quote_query, function(capture, node)
        local nested_info = NodeInfo.new(self.buf, node)
        logger.debug_node_info(capture, nested_info)

        if capture == 'quote_marker' then
            self:quote_marker(nested_info, info)
        else
            logger.unhandled_capture('markdown quote', capture)
        end
    end)
end

---@private
---@param info render.md.NodeInfo
---@param block_quote render.md.NodeInfo
function Render:quote_marker(info, block_quote)
    if not self.config.enabled then
        return
    end
    local callout = component.callout(self.buf, block_quote.text, 'contains')
    local highlight = callout ~= nil and callout.highlight or self.config.highlight
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { info.text:gsub('>', self.config.icon), highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = self.config.repeat_linebreak or nil,
    })
end

return Render
