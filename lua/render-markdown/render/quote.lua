local Base = require('render-markdown.render.base')
local treesitter = require('render-markdown.core.treesitter')

---@class render.md.data.Quote
---@field query vim.treesitter.Query
---@field icon string
---@field highlight string
---@field repeat_linebreak? boolean

---@class render.md.render.Quote: render.md.Renderer
---@field private data render.md.data.Quote
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
    local quote = self.config.quote
    if not quote.enabled then
        return false
    end

    local callout = self.context:get_callout(self.info)

    self.data = {
        query = treesitter.parse(
            'markdown',
            [[
                [
                    (block_quote_marker)
                    (block_continuation)
                ] @quote_marker
            ]]
        ),
        icon = callout ~= nil and callout.quote_icon or quote.icon,
        highlight = callout ~= nil and callout.highlight or quote.highlight,
        repeat_linebreak = quote.repeat_linebreak or nil,
    }

    return true
end

function Render:render()
    self.context:query(self.info:get_node(), self.data.query, function(capture, info)
        assert(capture == 'quote_marker', 'Unhandled quote capture: ' .. capture)
        self:quote_marker(info)
    end)
end

---@private
---@param info render.md.NodeInfo
function Render:quote_marker(info)
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { info.text:gsub('>', self.data.icon), self.data.highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = self.data.repeat_linebreak,
    })
end

return Render
