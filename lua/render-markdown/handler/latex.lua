local Context = require('render-markdown.request.context')
local Indent = require('render-markdown.lib.indent')
local Marks = require('render-markdown.lib.marks')
local Node = require('render-markdown.lib.node')
local env = require('render-markdown.lib.env')
local iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local str = require('render-markdown.lib.str')

---@class render.md.latex.Item
---@field node render.md.Node
---@field output string[]
---@field width integer
---@field position render.md.latex.Position
---@field above integer
---@field below integer

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

    local cmds = env.commands(self.config.converter)
    if #cmds == 0 then
        log.add('debug', 'ConverterNotFound', self.config.converter)
        return {}
    end

    local node = Node.new(self.context.buf, root)
    local count = str.char_count(node.text, '$')
    local include = (count <= 1 and self.config.inline)
        or (count >= 2 and self.config.block)
    if include then
        log.node('latex', node)
        self.context.latex:add(node)
    end

    if last then
        local nodes = self.context.latex:get()
        local inputs = Handler.inputs(nodes)
        for _, cmd in ipairs(cmds) do
            inputs = Handler.convert(cmd, inputs)
        end
        for _, input in ipairs(inputs) do
            log.add('error', 'ConvertersFailed', input)
            Handler.cache[input] = 'error'
        end
        local rows = self:rows(nodes)
        for row, items in pairs(rows) do
            self:render(row, items)
        end
    end

    return self.marks:get()
end

---@private
---@param nodes render.md.Node[]
---@return string[]
function Handler.inputs(nodes)
    local inputs = {} ---@type string[]
    for _, node in ipairs(nodes) do
        local input = Handler.input(node)
        if not Handler.cache[input] and not vim.tbl_contains(inputs, input) then
            inputs[#inputs + 1] = input
        end
    end
    return inputs
end

---@private
---@param node render.md.Node
---@return string
function Handler.input(node)
    local text = node.text
    return vim.trim(text:match('^%$*(.-)%$*$') or text)
end

---@private
---@param cmd string
---@param inputs string[]
---@return string[]
function Handler.convert(cmd, inputs)
    local failed = {} ---@type string[]
    if vim.system then
        local tasks = {} ---@type table<string, vim.SystemObj>
        for _, input in ipairs(inputs) do
            tasks[input] = vim.system({ cmd }, { stdin = input, text = true })
        end
        for input, task in pairs(tasks) do
            local output = task:wait()
            local result = output.stdout
            if output.code == 0 and result then
                Handler.cache[input] = result
            else
                failed[#failed + 1] = input
            end
        end
    else
        for _, input in ipairs(inputs) do
            local result = vim.fn.system(cmd, input)
            if vim.v.shell_error == 0 and result then
                Handler.cache[input] = result
            else
                failed[#failed + 1] = input
            end
        end
    end
    return failed
end

---@private
---@param nodes render.md.Node[]
---@return table<integer, render.md.latex.Item[]>
function Handler:rows(nodes)
    ---@param node render.md.Node
    ---@return integer, integer
    local function get(node)
        if self.config.position == 'below' and node:height() > 1 then
            return node.end_row, 0
        else
            return node.start_row, node.start_col
        end
    end

    table.sort(nodes, function(a, b)
        local a_row, a_col = get(a)
        local b_row, b_col = get(b)
        return a_row == b_row and a_col < b_col or a_row < b_row
    end)

    local result = {} ---@type table<integer, render.md.latex.Item[]>
    for _, node in ipairs(nodes) do
        local item = self:item(node)
        if item then
            local row = get(node)
            result[row] = result[row] or {}
            local items = result[row]
            items[#items + 1] = item
        end
    end
    return result
end

---@private
---@param node render.md.Node
---@return render.md.latex.Item?
function Handler:item(node)
    local output = str.split(Handler.cache[Handler.input(node)], '\n', true)
    if #output == 0 then
        return nil
    end

    -- add top and bottom padding
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

    -- determine position based on config and height
    local position = self.config.position
    if position == 'center' and node:height() > 1 then
        position = 'above'
    elseif position == 'replace' and node:height() == 1 then
        position = 'center'
    end

    local above, below = 0, 0
    if position == 'above' then
        above = #output
    elseif position == 'below' then
        below = #output
    elseif position == 'center' then
        above = math.floor(#output / 2)
        below = #output - above - 1
    end

    ---@type render.md.latex.Item
    return {
        node = node,
        output = output,
        width = width,
        position = position,
        above = above,
        below = below,
    }
end

---@private
---@param row integer
---@param items render.md.latex.Item[]
function Handler:render(row, items)
    local max_above, max_below = 0, 0
    for _, item in ipairs(items) do
        max_above = math.max(max_above, item.above)
        max_below = math.max(max_below, item.below)
    end

    local indent = self:indent(items[1].node)
    local highlight = self.config.highlight

    local current = 0
    local above = vim.fn['repeat']({ '' }, max_above) ---@type string[]
    local below = vim.fn['repeat']({ '' }, max_below) ---@type string[]

    for _, item in ipairs(items) do
        -- absolute formula column
        local column ---@type integer
        if item.position == 'below' and item.node:height() > 1 then
            -- latex blocks include last line, unlike markdown blocks
            local _, line = item.node:line('below', 1)
            column = line and str.spaces('start', line) or 0
        else
            local _, line = item.node:line('first', 0)
            column = self.context:width({
                text = line and line:sub(1, item.node.start_col) or '',
                start_row = item.node.start_row,
                start_col = 0,
                end_row = item.node.start_row,
                end_col = item.node.start_col,
            })
        end

        -- convert column to relative offset, include padding between formulas
        local prefix = math.max(column - current, current == 0 and 0 or 1)

        -- concatenate output onto lines
        for i, line in ipairs(above) do
            local index = i - (#above - item.above)
            local body = item.output[index] or str.pad(item.width)
            above[i] = line .. str.pad(prefix) .. body
        end
        for i, line in ipairs(below) do
            local index = i + (#item.output - item.below)
            local body = item.output[index] or str.pad(item.width)
            below[i] = line .. str.pad(prefix) .. body
        end

        -- replace: conceal source and show rendered output
        if item.position == 'replace' then
            local lines = iter.list.map(item.output, function(line)
                return indent:copy():text(line, highlight):get()
            end)
            self.marks:replace(self.config, item.node, lines)
        else
            -- update current width of lines
            current = current + prefix + item.width

            -- render center line
            if item.position == 'center' then
                self.marks:over(self.config, 'latex', item.node, {
                    virt_text = { { item.output[item.above + 1], highlight } },
                    virt_text_pos = 'inline',
                    conceal = '',
                })
            end
        end
    end

    ---@param lines string[]
    ---@param position 'above'|'below'
    local function add_lines(lines, position)
        if #lines == 0 then
            return
        end
        self.marks:add(self.config, 'virtual_lines', row, 0, {
            virt_lines = iter.list.map(lines, function(line)
                return indent:copy():text(line, highlight):get()
            end),
            virt_lines_above = position == 'above',
        })
    end

    add_lines(above, 'above')
    add_lines(below, 'below')
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
    end
    return Indent.new(self.context, Node.new(buf, markdown)):line(true)
end

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):run(ctx.root, ctx.last)
end

return M
