local Context = require('render-markdown.request.context')
local Indent = require('render-markdown.lib.indent')
local Marks = require('render-markdown.lib.marks')
local Node = require('render-markdown.lib.node')
local iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local str = require('render-markdown.lib.str')

---@class render.md.handler.buf.Latex
---@field private context render.md.request.Context
---@field private config render.md.latex.Config
local Handler = {}
Handler.__index = Handler

---@private
---@type table<string, string>
Handler.cache = {}

---@param buf integer
---@return render.md.handler.buf.Latex
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.context = Context.get(buf)
    self.config = self.context.config.latex
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:run(root)
    if self.context:skip(self.config) then
        return {}
    end
    if vim.fn.executable(self.config.converter) ~= 1 then
        log.add('debug', 'ConverterNotFound', self.config.converter)
        return {}
    end

    local node = Node.new(self.context.buf, root)
    log.node('latex', node)

    local indent = self:indent(node.start_row, node.start_col)
    local lines = iter.list.map(self:expressions(node), function(expression)
        local line = vim.list_extend({}, indent)
        line[#line + 1] = { expression, self.config.highlight }
        return line
    end)

    local above = self.config.position == 'above'
    local row = above and node.start_row or node.end_row

    local marks = Marks.new(self.context, true)
    marks:add(false, row, 0, {
        virt_lines = lines,
        virt_lines_above = above,
    })
    return marks:get()
end

---@private
---@param node render.md.Node
---@return string[]
function Handler:expressions(node)
    local result = {} ---@type string[]
    for _ = 1, self.config.top_pad do
        result[#result + 1] = ''
    end
    local lines = str.split(self:convert(node.text), '\n', true)
    local width = vim.fn.max(iter.list.map(lines, str.width))
    for _, line in ipairs(lines) do
        local prefix = str.pad(node.start_col)
        local suffix = str.pad(width - str.width(line))
        result[#result + 1] = prefix .. line .. suffix
    end
    for _ = 1, self.config.bottom_pad do
        result[#result + 1] = ''
    end
    return result
end

---@private
---@param text string
---@return string
function Handler:convert(text)
    local result = Handler.cache[text]
    if not result then
        local converter = self.config.converter
        result = vim.fn.system(converter, text)
        if vim.v.shell_error == 1 then
            log.add('error', 'ConverterFailed', converter, result)
            result = 'error'
        end
        Handler.cache[text] = result
    end
    return result
end

---@private
---@param row integer
---@param col integer
---@return render.md.mark.Line
function Handler:indent(row, col)
    local buf = self.context.buf
    local node = vim.treesitter.get_node({
        bufnr = buf,
        pos = { row, col },
        lang = 'markdown',
    })
    if not node then
        return {}
    end
    return Indent.new(self.context, Node.new(buf, node)):line(true):get()
end

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):run(ctx.root)
end

return M
