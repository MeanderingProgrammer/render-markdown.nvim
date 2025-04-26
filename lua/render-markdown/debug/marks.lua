---@class render.md.debug.Range
---@field [1] integer
---@field [2]? integer

---@class render.md.debug.Mark
---@field conceal boolean
---@field opts render.md.mark.Opts
---@field row render.md.debug.Range
---@field col render.md.debug.Range
local Mark = {}
Mark.__index = Mark

---@param mark render.md.Mark
---@return render.md.debug.Mark
function Mark.new(mark)
    local self = setmetatable({}, Mark)
    self.conceal, self.opts = mark.conceal, mark.opts
    self.row = { mark.start_row, mark.opts.end_row }
    self.col = { mark.start_col, mark.opts.end_col }
    return self
end

---@param a render.md.debug.Mark
---@param b render.md.debug.Mark
---@return boolean
function Mark.__lt(a, b)
    local as, bs = a:priorities(), b:priorities()
    assert(#as == #bs)
    for i = 1, #as do
        if as[i] ~= bs[i] then
            return as[i] < bs[i]
        end
    end
    return false
end

---@private
---@return number[]
function Mark:priorities()
    local virt_row = 0
    if self.opts.virt_lines ~= nil then
        virt_row = self.opts.virt_lines_above and -0.5 or 0.5
    end
    local win_col = self.opts.virt_text_win_col or 0
    ---@type number[]
    return {
        -- rows
        self.row[1] + virt_row,
        (self.row[2] or self.row[1]) + virt_row,
        -- cols
        math.max(self.col[1], win_col),
        math.max((self.col[2] or self.col[1]), win_col),
    }
end

---@return string
function Mark:__tostring()
    local lines = {}
    lines[#lines + 1] = string.rep('=', vim.o.columns - 1)
    lines[#lines + 1] = string.format('row: %s', Mark.collapse(self.row))
    lines[#lines + 1] = string.format('column: %s', Mark.collapse(self.col))
    lines[#lines + 1] = string.format('hide: %s', vim.inspect(self.conceal))

    ---@param name string
    ---@param f fun(value: any): string
    local function add(name, f)
        local value = self.opts[name]
        if value ~= nil then
            lines[#lines + 1] = string.format('  %s: %s', name, f(value))
        end
    end

    add('conceal', vim.inspect)
    add('conceal_lines', vim.inspect)
    add('sign_text', Mark.text)
    add('sign_hl_group', Mark.highlight)
    add('virt_text', Mark.line)
    add('virt_text_pos', tostring)
    add('virt_text_win_col', vim.inspect)
    add('virt_text_repeat_linebreak', vim.inspect)
    add('virt_lines', Mark.lines)
    add('virt_lines_above', vim.inspect)
    add('hl_group', Mark.highlight)
    add('hl_eol', vim.inspect)
    add('hl_mode', tostring)
    add('priority', tostring)
    return table.concat(lines, '\n')
end

---@private
---@param range render.md.debug.Range
---@return string
function Mark.collapse(range)
    local s, e = range[1], range[2]
    return e == nil and tostring(s) or string.format('%d -> %d', s, e)
end

---@private
---@param lines render.md.mark.Line[]
---@return string
function Mark.lines(lines)
    return #lines > 0 and Mark.line(lines[1]) or ''
end

---@private
---@param line render.md.mark.Line
---@return string
function Mark.line(line)
    local result = {}
    for _, text in ipairs(line) do
        result[#result + 1] = string.format(
            '(%s, %s)',
            Mark.text(text[1]),
            Mark.highlight(text[2])
        )
    end
    return table.concat(result, ' + ')
end

---@private
---@param text string
---@return string
function Mark.text(text)
    local chars = vim.fn.str2list(text)
    local first, same = chars[1], true
    for _, char in ipairs(chars) do
        same = same and (first == char)
    end
    if #chars > 1 and same then
        local char = vim.fn.nr2char(first)
        return string.format('rep(%s, %d)', char, #chars)
    else
        return text
    end
end

---@private
---@param highlight string|string[]
---@return string
function Mark.highlight(highlight)
    if type(highlight) == 'table' then
        highlight = table.concat(highlight, '+')
    end
    local result = highlight:gsub('RenderMarkdown', 'Rm')
    return result
end

---@class render.md.debug.Marks
local M = {}

function M.show()
    local Env = require('render-markdown.lib.env')
    local Iter = require('render-markdown.lib.iter')
    local ui = require('render-markdown.core.ui')

    local buf = Env.buf.current()
    local win = Env.win.current()
    local row = assert(Env.row.get(buf, win), 'row must be known')
    local marks = ui.row_marks(buf, row)

    vim.print(string.format('row: %d', row))
    if #marks == 0 then
        vim.print('no decorations found')
    else
        local debug_marks = Iter.list.map(marks, Mark.new)
        table.sort(debug_marks)
        for _, mark in ipairs(debug_marks) do
            vim.print(tostring(mark))
        end
    end
end

return M
