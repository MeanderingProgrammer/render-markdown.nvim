local Context = require('render-markdown.core.context')
local Marks = require('render-markdown.lib.marks')
local state = require('render-markdown.state')
local ts = require('render-markdown.integ.ts')

---@class render.md.handler.buf.Markdown
---@field private config render.md.BufferConfig
---@field private context render.md.Context
---@field private marks render.md.Marks
---@field private query vim.treesitter.Query
---@field private renderers table<string, render.md.Renderer>
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.config = state.get(buf)
    self.context = Context.get(buf)
    self.marks = Marks.new(buf, false)
    self.query = ts.parse(
        'markdown',
        [[
            (section) @section

            [
                (atx_heading)
                (setext_heading)
            ] @heading

            (section (paragraph) @paragraph)

            (fenced_code_block) @code

            [
                (thematic_break)
                (minus_metadata)
                (plus_metadata)
            ] @dash

            (list_item) @bullet

            [
                (task_list_marker_unchecked)
                (task_list_marker_checked)
            ] @checkbox

            (block_quote) @quote

            (pipe_table) @table
        ]]
    )
    self.renderers = {
        bullet = require('render-markdown.render.bullet'),
        checkbox = require('render-markdown.render.checkbox'),
        code = require('render-markdown.render.code'),
        dash = require('render-markdown.render.dash'),
        heading = require('render-markdown.render.heading'),
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
    self.context:query(root, self.query, function(capture, node)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'Unhandled markdown capture: ' .. capture)
        local render = renderer:new(self.marks, self.config, self.context, node)
        if render:setup() then
            render:render()
        end
    end)
    return self.marks:get()
end

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
