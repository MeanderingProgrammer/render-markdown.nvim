local Context = require('render-markdown.request.context')
local Indent = require('render-markdown.lib.indent')
local Marks = require('render-markdown.lib.marks')
local Node = require('render-markdown.lib.node')
local env = require('render-markdown.lib.env')
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
    local cmd = env.command(self.config.converter)
    if not cmd then
        log.add('debug', 'ConverterNotFound', self.config.converter)
        return {}
    end
    local node = Node.new(self.context.buf, root)
    log.node('latex', node)
    self.context.latex:add(node)
    if last then
        local nodes = self.context.latex:get()
        Handler.convert(cmd, nodes)
        local rows = self:rows(nodes)
        for row, row_nodes in pairs(rows) do
            self:render(row, row_nodes)
        end
    end
    return self.marks:get()
end

---@private
---@param cmd string
---@param nodes render.md.Node[]
function Handler.convert(cmd, nodes)
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
---@param node render.md.Node
---@return string
function Handler.text(node)
    local s = node.text
    return vim.trim(s:match('^%$*(.-)%$*$') or s)
end

---@private
---@param nodes render.md.Node[]
---@return table<integer, render.md.Node[]>
function Handler:rows(nodes)
    local position = self.config.position

    ---@param node render.md.Node
    ---@return integer, integer
    local function get(node)
        if position == 'below' and node:height() > 1 then
            return node.end_row, 0
        else
            return node.start_row, node.start_col
        end
    end

    table.sort(nodes, function(a, b)
        local a_row, a_col = get(a)
        local b_row, b_col = get(b)
        if a_row ~= b_row then
            return a_row < b_row
        else
            return a_col < b_col
        end
    end)

    local result = {} ---@type table<integer, render.md.Node[]>
    for _, node in ipairs(nodes) do
        local node_row = get(node)
        if not result[node_row] then
            result[node_row] = {}
        end
        local row = result[node_row]
        row[#row + 1] = node
    end
    return result
end

---@private
---@param row integer
---@param nodes render.md.Node[]
function Handler:render(row, nodes)
    local first = nodes[1]
    local indent = self:indent(first)

    local lines_above = {} ---@type string[]
    local lines_below = {} ---@type string[]
    local current = 0

    for _, node in ipairs(nodes) do
        local output = str.split(Handler.cache[Handler.text(node)], '\n', true)

        -- add top and bottom padding around output
        for _ = 1, self.config.top_pad do
            table.insert(output, 1, '')
        end
        for _ = 1, self.config.bottom_pad do
            output[#output + 1] = ''
        end

        -- pad lines to the same width
        local width = vim.fn.max(iter.list.map(output, str.width))
        for i, line in ipairs(output) do
            output[i] = line .. str.pad(width - str.width(line))
        end

        -- center is only possible if formula is a single line
        local position = self.config.position
        if position == 'center' and node:height() > 1 then
            position = 'above'
        end

        -- absolute formula column
        local col ---@type integer
        if position == 'below' and node:height() > 1 then
            -- latex blocks include last line, unlike markdown blocks
            local _, line = node:line('below', 1)
            col = line and str.spaces('start', line) or 0
        else
            local _, line = node:line('above', 0)
            col = self.context:width({
                text = line and line:sub(1, node.start_col) or '',
                start_row = node.start_row,
                start_col = 0,
                end_row = node.start_row,
                end_col = node.start_col,
            })
        end

        -- convert column to relative offset, include padding between formulas
        local prefix = math.max(col - current, current == 0 and 0 or 1)

        local above ---@type integer
        local below ---@type integer
        if position == 'above' then
            above = #output
            below = 0
        elseif position == 'below' then
            above = 0
            below = #output
        else
            assert(node:height() == 1, 'invalid center height')
            local center = math.floor(#output / 2) + 1
            above = center - 1
            below = #output - center
            self.marks:over(self.config, true, node, {
                virt_text = { { output[center], self.config.highlight } },
                virt_text_pos = 'inline',
                conceal = '',
            })
        end

        -- fill in new lines at top and bottom
        while #lines_above < above do
            table.insert(lines_above, 1, str.pad(current))
        end
        while #lines_below < below do
            lines_below[#lines_below + 1] = str.pad(current)
        end

        -- concatenate output onto lines
        for i, line in ipairs(lines_above) do
            local index = i - (#lines_above - above)
            local body = output[index] or str.pad(width)
            lines_above[i] = line .. str.pad(prefix) .. body
        end
        for i, line in ipairs(lines_below) do
            local index = i + (#output - below)
            local body = output[index] or str.pad(width)
            lines_below[i] = line .. str.pad(prefix) .. body
        end

        -- update current width of lines
        current = current + prefix + width
    end

    ---@param lines string[]
    ---@param above boolean
    local function add_lines(lines, above)
        if #lines == 0 then
            return
        end
        self.marks:add(self.config, 'virtual_lines', row, 0, {
            virt_lines = iter.list.map(lines, function(line)
                return indent:copy():text(line, self.config.highlight):get()
            end),
            virt_lines_above = above,
        })
    end

    add_lines(lines_above, true)
    add_lines(lines_below, false)
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

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):run(ctx.root, ctx.last)
end

return M
