local Context = require('render-markdown.core.context')
local list = require('render-markdown.core.list')
local state = require('render-markdown.state')
local treesitter = require('render-markdown.core.treesitter')

---@class render.md.handler.buf.Markdown
---@field private marks render.md.Marks
---@field private config render.md.buffer.Config
---@field private context render.md.Context
---@field private query vim.treesitter.Query
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
    self.query = treesitter.parse(
        'markdown',
        [[
            (section) @section

            (atx_heading [
                (atx_h1_marker)
                (atx_h2_marker)
                (atx_h3_marker)
                (atx_h4_marker)
                (atx_h5_marker)
                (atx_h6_marker)
            ] @heading)
            (setext_heading) @heading

            (section (paragraph) @paragraph)

            (fenced_code_block) @code

            [
                (thematic_break)
                (minus_metadata)
                (plus_metadata)
            ] @dash

            [
                (list_marker_plus)
                (list_marker_minus)
                (list_marker_star)
            ] @list_marker

            [
                (task_list_marker_unchecked)
                (task_list_marker_checked)
            ] @checkbox

            (block_quote) @quote

            (pipe_table) @table
        ]]
    )
    self.renderers = {
        checkbox = require('render-markdown.render.checkbox'),
        code = require('render-markdown.render.code'),
        dash = require('render-markdown.render.dash'),
        heading = require('render-markdown.render.heading'),
        list_marker = require('render-markdown.render.list_marker'),
        paragraph = require('render-markdown.render.paragraph'),
        quote = require('render-markdown.render.quote'),
        section = require('render-markdown.render.section'),
        table = require('render-markdown.render.table'),
    }
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    self.context:query(root, self.query, function(capture, info)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'Unhandled markdown capture: ' .. capture)
        local render = renderer:new(self.marks, self.config, self.context, info)
        if render:setup() then
            render:render()
        end
    end)
    return self.marks:get()
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
