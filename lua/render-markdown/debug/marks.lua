local Iter = require('render-markdown.lib.iter')

---@class render.md.debug.Mark
---@field conceal boolean
---@field opts vim.api.keyset.set_extmark
---@field row { [1]: integer, [2]: integer }
---@field col { [1]: integer, [2]: integer }
local Mark = {}
Mark.__index = Mark

---@param mark render.md.Mark
---@return render.md.debug.Mark
function Mark.new(mark)
    local self = setmetatable({}, Mark)
    self.conceal, self.opts = mark.conceal, mark.opts
    self.row = { mark.start_row, mark.opts.end_row or mark.start_row }
    self.col = { mark.start_col, mark.opts.end_col or mark.start_col }
    return self
end

---@return integer[]
function Mark:priorities()
    local row_offset = 0
    if self.opts.virt_lines ~= nil then
        row_offset = self.opts.virt_lines_above and -0.5 or 0.5
    end
    local col = self.opts.virt_text_win_col or 0
    local result = { self.row[1] + row_offset, self.row[2] + row_offset }
    return vim.list_extend(result, { math.max(self.col[1], col), math.max(self.col[2], col) })
end

---@return string
function Mark:__tostring()
    ---@param text string
    ---@return string
    local function serialize_text(text)
        local chars = vim.fn.str2list(text)
        if #chars <= 1 then
            return string.format('"%s"', text)
        end
        local first = chars[1]
        for _, char in ipairs(chars) do
            if first ~= char then
                return string.format('"%s"', text)
            end
        end
        return string.format('rep(%s, %d)', vim.fn.nr2char(first), #chars)
    end

    ---@param highlight number|string|string[]
    ---@return string
    local function serialize_highlight(highlight)
        if type(highlight) == 'table' then
            highlight = table.concat(highlight, '+')
        end
        local result, _ = highlight:gsub('RenderMarkdown_?', '')
        result, _ = result:gsub('Inverse', 'I')
        return string.format('(%s)', result)
    end

    ---@param line { [1]?: string, [2]?: number|string|string[] }[]
    ---@return string[]?
    local function virt_line(line)
        local result = {}
        for _, part in ipairs(line) do
            local serialized, text, highlight = {}, part[1], part[2]
            if text ~= nil then
                table.insert(serialized, serialize_text(text))
            end
            if highlight ~= nil then
                table.insert(serialized, serialize_highlight(highlight))
            end
            if #serialized > 0 then
                table.insert(result, table.concat(serialized, '::'))
            end
        end
        return #result > 0 and result or nil
    end

    ---@param vals { [1]: integer, [2]: integer }
    ---@return string|integer
    local function collapse(vals)
        return vals[1] == vals[2] and vals[1] or string.format('%d -> %d', vals[1], vals[2])
    end

    local lines = {
        string.rep('=', vim.o.columns - 10),
        string.format('row: %s', collapse(self.row)),
        string.format('column: %s', collapse(self.col)),
        string.format('hide: %s', self.conceal),
    }

    ---@param name string
    ---@param value any
    local function append(name, value)
        if type(value) == 'table' then
            value = virt_line(value)
        end
        if value ~= nil then
            if type(value) == 'table' then
                value = table.concat(value, ' + ')
            end
            if type(value) == 'string' and #value == 0 then
                value = vim.inspect(value)
            end
            table.insert(lines, string.format('  %s: %s', name, value))
        end
    end

    append('conceal', self.opts.conceal)
    append('sign', { { self.opts.sign_text, self.opts.sign_hl_group } })
    append('virt_text', self.opts.virt_text)
    append('virt_text_pos', self.opts.virt_text_pos)
    append('virt_text_win_col', self.opts.virt_text_win_col)
    append('virt_text_repeat_linebreak', self.opts.virt_text_repeat_linebreak)
    append('virt_line', (self.opts.virt_lines or {})[1])
    append('virt_line_above', self.opts.virt_lines_above)
    append('hl_group', { { nil, self.opts.hl_group } })
    append('hl_eol', self.opts.hl_eol)
    append('hl_mode', self.opts.hl_mode)
    append('priority', self.opts.priority)
    return table.concat(lines, '\n')
end

---@param a render.md.debug.Mark
---@param b render.md.debug.Mark
---@return boolean
function Mark.__lt(a, b)
    local as, bs = a:priorities(), b:priorities()
    for i = 1, math.max(#as, #bs) do
        if as[i] ~= bs[i] then
            return as[i] < bs[i]
        end
    end
    return false
end

---@class render.md.debug.Marks
local M = {}

---@param row integer
---@param marks render.md.Mark[]
function M.debug(row, marks)
    print(string.format('Decorations on row: %d', row))
    if #marks == 0 then
        print('No decorations found')
    end
    local debug_marks = Iter.list.map(marks, Mark.new)
    table.sort(debug_marks)
    for _, mark in ipairs(debug_marks) do
        print(mark)
    end
end

return M
