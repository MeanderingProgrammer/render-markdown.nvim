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
    if not self.config.enabled then
        return {}
    end
    if vim.fn.executable(self.config.converter) ~= 1 then
        log.add('debug', 'ConverterNotFound', self.config.converter)
        return {}
    end

    local node = Node.new(self.context.buf, root)
    log.node('latex', node)

    local marks = Marks.new(self.context, true)
    local output = str.split(self:convert(node.text), '\n', true)
    if self.config.virtual or #output > 1 then
        local col = node.start_col
        local _, first = node:line('first', 0)
        local prefix = str.pad(first and str.width(first:sub(1, col)) or col)
        local width = vim.fn.max(iter.list.map(output, str.width))

        local text = {} ---@type string[]
        for _ = 1, self.config.top_pad do
            text[#text + 1] = ''
        end
        for _, line in ipairs(output) do
            local suffix = str.pad(width - str.width(line))
            text[#text + 1] = prefix .. line .. suffix
        end
        for _ = 1, self.config.bottom_pad do
            text[#text + 1] = ''
        end

        local indent = self:indent(node.start_row, col)
        local lines = iter.list.map(text, function(part)
            local line = vim.list_extend({}, indent) ---@type render.md.mark.Line
            line[#line + 1] = { part, self.config.highlight }
            return line
        end)

        local above = self.config.position == 'above'
        local row = above and node.start_row or node.end_row

        marks:add(self.config, 'virtual_lines', row, 0, {
            virt_lines = lines,
            virt_lines_above = above,
        })
    else
        marks:over(self.config, true, node, {
            virt_text = { { output[1], self.config.highlight } },
            virt_text_pos = 'inline',
            conceal = '',
        })
    end
    return marks:get()
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
