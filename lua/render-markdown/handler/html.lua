local Context = require('render-markdown.core.context')
local List = require('render-markdown.lib.list')
local state = require('render-markdown.state')
local treesitter = require('render-markdown.core.treesitter')

---@class render.md.handler.buf.Html
---@field private config render.md.Html
---@field private context render.md.Context
---@field private marks render.md.Marks
---@field private query vim.treesitter.Query
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Html
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.config = state.html
    self.context = Context.get(buf)
    self.marks = List.new_marks(buf, true)
    self.query = treesitter.parse('html', '(comment) @comment')
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    if self.config.enabled and self.config.conceal_comments then
        self.context:query(root, self.query, function(capture, node)
            assert(capture == 'comment', 'Unhandled html capture: ' .. capture)
            self.marks:add_over(true, node, {
                conceal = '',
            })
        end)
    end
    return self.marks:get()
end

---@class render.md.handler.Html: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    return Handler.new(buf):parse(root)
end

return M
