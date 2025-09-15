local Context = require('render-markdown.request.context')
local Indent = require('render-markdown.lib.indent')
local Marks = require('render-markdown.lib.marks')
local Node = require('render-markdown.lib.node')
local iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local str = require('render-markdown.lib.str')

---@class render.md.handler.buf.Latex
---@field private context render.md.request.Context
---@field private marks render.md.Marks
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
    self.marks = Marks.new(self.context, true)
    self.config = self.context.config.latex
    return self
end

---@param root TSNode
---@param last boolean
---@return render.md.Mark[]
function Handler:run(root, last)
    if not self.config.enabled then
        return {}
    end
    if vim.fn.executable(self.config.converter) ~= 1 then
        log.add('debug', 'ConverterNotFound', self.config.converter)
        return {}
    end
    local node = Node.new(self.context.buf, root)
    log.node('latex', node)
    self.context.latex:add(node)
    if last then
        local nodes = self.context.latex:get()
        self:convert(nodes)
        for _, row in ipairs(self:rows(nodes)) do
            self:render(row)
        end
    end
    return self.marks:get()
end

---@private
---@param nodes render.md.Node[]
function Handler:convert(nodes)
    local cmd = self.config.converter
    local inputs = {} ---@type string[]
    for _, node in ipairs(nodes) do
        local text = Handler.text(node)
        if not Handler.cache[text] and not vim.tbl_contains(inputs, text) then
            inputs[#inputs + 1] = text
        end
    end
    if vim.system then
        local tasks = {} ---@type table<string, vim.SystemObj>
        for _, text in ipairs(inputs) do
            tasks[text] = vim.system({ cmd }, { stdin = text, text = true })
        end
        for text, task in pairs(tasks) do
            local output = task:wait()
            local result = output.stdout
            if output.code ~= 0 or not result then
                log.add('error', 'ConverterFailed', cmd, result)
                result = 'error'
            end
            Handler.cache[text] = result
        end
    else
        for _, text in ipairs(inputs) do
            local result = vim.fn.system(cmd, text)
            if vim.v.shell_error == 1 then
                log.add('error', 'ConverterFailed', cmd, result)
                result = 'error'
            end
            Handler.cache[text] = result
        end
    end
end

---@private
---@param nodes render.md.Node[]
---@return render.md.Node[][]
function Handler:rows(nodes)
    table.sort(nodes)
    local result = {} ---@type render.md.Node[][]
    result[#result + 1] = { nodes[1] }
    for i = 2, #nodes do
        local node, last = nodes[i], result[#result]
        if node.start_row == last[#last].start_row then
            last[#last + 1] = node
        else
            result[#result + 1] = { node }
        end
    end
    return result
end

---@private
---@param nodes render.md.Node[]
function Handler:render(nodes)
    local first = nodes[1]
    local indent = self:indent(first)
    local _, line = first:line('first', 0)

    for _, node in ipairs(nodes) do
        local output = str.split(Handler.cache[Handler.text(node)], '\n', true)
        if self.config.virtual or #output > 1 then
            local col = node.start_col
            local prefix = str.pad(line and str.width(line:sub(1, col)) or col)
            local width = vim.fn.max(iter.list.map(output, str.width))

            local texts = {} ---@type string[]
            for _ = 1, self.config.top_pad do
                texts[#texts + 1] = ''
            end
            for _, text in ipairs(output) do
                local suffix = str.pad(width - str.width(text))
                texts[#texts + 1] = prefix .. text .. suffix
            end
            for _ = 1, self.config.bottom_pad do
                texts[#texts + 1] = ''
            end

            local lines = iter.list.map(texts, function(text)
                return indent:copy():text(text, self.config.highlight):get()
            end)

            local above = self.config.position == 'above'
            local row = above and node.start_row or node.end_row

            self.marks:add(self.config, 'virtual_lines', row, 0, {
                virt_lines = lines,
                virt_lines_above = above,
            })
        else
            self.marks:over(self.config, true, node, {
                virt_text = { { output[1], self.config.highlight } },
                virt_text_pos = 'inline',
                conceal = '',
            })
        end
    end
end

---@private
---@param node render.md.Node
---@return render.md.Line
function Handler:indent(node)
    local buf = self.context.buf
    local markdown = vim.treesitter.get_node({
        bufnr = buf,
        pos = { node.start_row, node.start_col },
        lang = 'markdown',
    })
    if not markdown then
        return self.context.config:line()
    else
        return Indent.new(self.context, Node.new(buf, markdown)):line(true)
    end
end

---@private
---@param node render.md.Node
---@return string
function Handler.text(node)
    local s = node.text
    return vim.trim(s:match('^%$*(.-)%$*$') or s)
end

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):run(ctx.root, ctx.last)
end

return M
