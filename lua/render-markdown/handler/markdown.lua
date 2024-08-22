local Context = require('render-markdown.context')
local NodeInfo = require('render-markdown.node_info')
local RenderCode = require('render-markdown.render.code')
local RenderHeading = require('render-markdown.render.heading')
local RenderTable = require('render-markdown.render.table')
local component = require('render-markdown.component')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')

---@class render.md.handler.buf.Markdown
---@field private buf integer
---@field private marks render.md.Marks
---@field private config render.md.BufferConfig
---@field private context render.md.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.buf = buf
    self.marks = list.new_marks()
    self.config = state.get_config(buf)
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    self.context:query(root, state.markdown_query, function(capture, node)
        local info = NodeInfo.new(self.buf, node)
        logger.debug_node_info(capture, info)
        if capture == 'section' then
            self:section(info)
        elseif capture == 'heading' then
            RenderHeading.new(self.buf, self.marks, self.config, self.context):render(info)
        elseif capture == 'dash' then
            self:dash(info)
        elseif capture == 'code' then
            RenderCode.new(self.buf, self.marks, self.config, self.context):render(info)
        elseif capture == 'list_marker' then
            self:list_marker(info)
        elseif capture == 'checkbox_unchecked' then
            self:checkbox(info, self.config.checkbox.unchecked)
        elseif capture == 'checkbox_checked' then
            self:checkbox(info, self.config.checkbox.checked)
        elseif capture == 'quote' then
            self.context:query(node, state.markdown_quote_query, function(nested_capture, nested_node)
                local nested_info = NodeInfo.new(self.buf, nested_node)
                logger.debug_node_info(nested_capture, nested_info)
                if nested_capture == 'quote_marker' then
                    self:quote_marker(nested_info, info)
                else
                    logger.unhandled_capture('markdown quote', nested_capture)
                end
            end)
        elseif capture == 'table' then
            RenderTable.new(self.buf, self.marks, self.config, self.context):render(info)
        else
            logger.unhandled_capture('markdown', capture)
        end
    end)
    return self.marks:get()
end

---@private
---@param info render.md.NodeInfo
function Handler:section(info)
    local indent = self.config.indent
    if not indent.enabled then
        return
    end

    -- Do not add any indentation on unknown or first level
    local heading = info:child('atx_heading')
    if heading == nil or heading:child('atx_h1_marker') ~= nil then
        return
    end

    -- Each level stacks inline marks so we do not need to multiply spaces
    -- However skipping a level, i.e. 2 -> 5, will only add one level of spaces
    for row = info.start_row, info.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = { { str.spaces(indent.per_level), 'Normal' } },
            virt_text_pos = 'inline',
        })
    end
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
function Handler:list_marker(info)
    ---@return boolean
    local function sibling_checkbox()
        if not self.config.checkbox.enabled then
            return false
        end
        if info:sibling('task_list_marker_unchecked') ~= nil then
            return true
        end
        if info:sibling('task_list_marker_checked') ~= nil then
            return true
        end
        local paragraph = info:sibling('paragraph')
        return paragraph ~= nil and component.checkbox(self.buf, paragraph.text, 'starts') ~= nil
    end
    if sibling_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        self.marks:add(true, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            conceal = '',
        })
    else
        local bullet = self.config.bullet
        if not bullet.enabled then
            return
        end
        local level = info:level_in_section('list')
        local icon = list.cycle(bullet.icons, level)
        if icon == nil then
            return
        end
        -- List markers from tree-sitter should have leading spaces removed, however there are known
        -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we handle leading spaces here, can remove if this gets fixed upstream
        local leading_spaces = str.leading_spaces(info.text)
        self.marks:add(true, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { str.pad(leading_spaces, icon), bullet.highlight } },
            virt_text_pos = 'overlay',
        })
        if bullet.left_pad > 0 then
            self.marks:add(false, info.start_row, 0, {
                priority = 0,
                virt_text = { { str.spaces(bullet.left_pad), 'Normal' } },
                virt_text_pos = 'inline',
            })
        end
        if bullet.right_pad > 0 then
            self.marks:add(true, info.start_row, info.end_col - 1, {
                virt_text = { { str.spaces(bullet.right_pad), 'Normal' } },
                virt_text_pos = 'inline',
            })
        end
    end
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
        virt_text = { { inline and icon or str.pad_to(info.text, icon), highlight } },
        virt_text_pos = inline and 'inline' or 'overlay',
        conceal = inline and '' or nil,
    })
end

---@private
---@param info render.md.NodeInfo
---@param block_quote render.md.NodeInfo
function Handler:quote_marker(info, block_quote)
    local quote = self.config.quote
    if not quote.enabled then
        return
    end
    local callout = component.callout(self.buf, block_quote.text, 'contains')
    local highlight = callout ~= nil and callout.highlight or quote.highlight
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { info.text:gsub('>', quote.icon), highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = quote.repeat_linebreak or nil,
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
