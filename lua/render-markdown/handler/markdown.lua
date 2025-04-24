local Context = require('render-markdown.core.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.integ.ts')

---@class render.md.handler.buf.Markdown
---@field private query vim.treesitter.Query
---@field private renderers table<string, render.md.Render>
---@field private context render.md.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.query = ts.parse(
        'markdown',
        [[
            (document) @document

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
        document = require('render-markdown.render.document'),
        heading = require('render-markdown.render.heading'),
        paragraph = require('render-markdown.render.paragraph'),
        quote = require('render-markdown.render.quote'),
        section = require('render-markdown.render.section'),
        table = require('render-markdown.render.table'),
    }
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    local marks = Marks.new(self.context, false)
    self.context:query(root, self.query, function(capture, node)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'Unhandled markdown capture: ' .. capture)
        local render = renderer:new(self.context, marks, node)
        if render:setup() then
            render:render()
        end
    end)
    return marks:get()
end

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
