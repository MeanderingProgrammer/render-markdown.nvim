local Context = require('render-markdown.core.context')
local list = require('render-markdown.core.list')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local str = require('render-markdown.core.str')

---@class render.md.handler.buf.Markdown
---@field private marks render.md.Marks
---@field private config render.md.buffer.Config
---@field private context render.md.Context
---@field private renderers table<string, render.md.Renderer>
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.marks = list.new_marks()
    self.config = state.get(buf)
    self.context = Context.get(buf)
    self.renderers = {
        code = require('render-markdown.render.code'),
        heading = require('render-markdown.render.heading'),
        list_marker = require('render-markdown.render.list_marker'),
        quote = require('render-markdown.render.quote'),
        section = require('render-markdown.render.section'),
        table = require('render-markdown.render.table'),
    }
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    self.context:query(root, state.markdown_query, function(capture, info)
        local renderer = self.renderers[capture]
        if renderer ~= nil then
            local render = renderer:new(self.marks, self.config, self.context, info)
            if render:setup() then
                render:render()
            end
        elseif capture == 'dash' then
            self:dash(info)
        elseif capture == 'checkbox_unchecked' then
            self:checkbox(info, self.config.checkbox.unchecked)
        elseif capture == 'checkbox_checked' then
            self:checkbox(info, self.config.checkbox.checked)
        else
            log.unhandled_capture('markdown', capture)
        end
    end)
    return self.marks:get()
end

---@private
---@param info render.md.NodeInfo
function Handler:dash(info)
    local dash = self.config.dash
    if not dash.enabled then
        return
    end

    local width = dash.width
    width = type(width) == 'number' and width or self.context:get_width()

    self.marks:add(true, info.start_row, 0, {
        virt_text = { { dash.icon:rep(width), dash.highlight } },
        virt_text_pos = 'overlay',
    })
end

---@private
---@param info render.md.NodeInfo
---@param checkbox render.md.CheckboxComponent
function Handler:checkbox(info, checkbox)
    if not self.config.checkbox.enabled then
        return
    end
    local inline = self.config.checkbox.position == 'inline'
    local icon, highlight = checkbox.icon, checkbox.highlight
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { inline and icon or str.pad_to(info.text, icon) .. icon, highlight } },
        virt_text_pos = inline and 'inline' or 'overlay',
        conceal = inline and '' or nil,
    })
end

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    return Handler.new(buf):parse(root)
end

return M
