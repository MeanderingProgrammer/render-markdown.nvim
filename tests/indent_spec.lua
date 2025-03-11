---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param level integer
---@param position 'above'|'below'
---@return render.md.MarkInfo
local function border(row, level, position)
    local background = string.format('RenderMarkdown_bgtofg_RenderMarkdownH%dBg', level)
    local icon = position == 'above' and '▄' or '▀'
    local virtual = row == 0 and position == 'above'
    local line = {}
    if virtual then
        table.insert(line, { '  ', 'Normal' })
    end
    table.insert(line, { icon:rep(vim.o.columns), background })
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_text = not virtual and line or nil,
        virt_text_pos = not virtual and 'overlay' or nil,
        virt_lines = virtual and { line } or nil,
        virt_lines_above = virtual and position == 'above' or nil,
    }
end

---@param lengths integer[]
---@return render.md.MarkLine
local function indent_line(lengths)
    local result = {}
    for _, length in ipairs(lengths) do
        if length == 1 then
            table.insert(result, { '▎', 'RenderMarkdownIndent' })
        else
            table.insert(result, { string.rep(' ', length), 'Normal' })
        end
    end
    return result
end

---@param row integer
---@param lengths integer[]
---@return render.md.MarkInfo
local function indent(row, lengths)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_text = indent_line(lengths),
        virt_text_pos = 'inline',
        priority = 0,
    }
end

---@param mark render.md.MarkInfo
---@param lengths integer[]
---@return render.md.MarkInfo
local function indent_mark(mark, lengths)
    local line = indent_line(lengths)
    vim.list_extend(line, mark.virt_lines[1])
    mark.virt_lines = { line }
    return mark
end

describe('indent.md', function()
    it('with heading border & no icon', function()
        util.setup('tests/data/indent.md', {
            heading = { border = true },
            indent = { enabled = true, icon = '' },
        })

        local marks, row = util.marks(), util.row()

        local l2, l3 = { 2 }, { 4 }

        marks:add(border(row:get(), 2, 'above'))
        marks:add(indent(row:get(), l2))
        marks:extend(util.heading(row:get(), 2))
        marks:add(indent(row:inc(), l2))

        marks:add(indent_mark(util.table_border(row:inc(), true, { 5, 5 }), l2))
        marks:add(indent(row:get(), l2))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 6, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(indent(row:inc(), l2))
        marks:add(util.table_delimiter(row:get(), 13, { 5, 5 }))

        marks:add(border(row:inc(), 1, 'above'))
        marks:extend(util.heading(row:inc(), 1))
        marks:add(border(row:inc(), 1, 'below'))

        marks:add(indent(row:inc(2), l3))
        marks:add(border(row:get(), 3, 'above'))
        marks:add(indent(row:inc(), l3))
        marks:extend(util.heading(row:get(), 3))
        marks:add(indent(row:inc(), l3))
        marks:add(border(row:get(), 3, 'below'))

        marks:add(indent(row:inc(), l3))

        util.assert_view(marks, {
            '󰫎   1    󰲣 Heading 2',
            '    2',
            '        ┌─────┬─────┐',
            '    3   │ Foo │ Bar │',
            '    4   ├─────┼─────┤',
            '    5 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   6 󰲡 Heading 1',
            '    7 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '    8 Foo',
            '    9     ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎  10       󰲥 Heading 3',
            '   11     ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   12     Bar',
        })
    end)

    it('with per_level & skip_level', function()
        util.setup('tests/data/indent.md', {
            indent = { enabled = true, per_level = 4, skip_level = 0 },
        })

        local marks, row = util.marks(), util.row()

        local l1, l2 = { 1, 3 }, { 1, 3, 1, 3 }

        marks:add(indent(row:get(), l2))
        marks:extend(util.heading(row:get(), 2))
        marks:add(indent(row:inc(), l2))

        marks:add(indent_mark(util.table_border(row:inc(), true, { 5, 5 }), l2))
        marks:add(indent(row:get(), l2))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 6, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(indent(row:inc(), l2))
        marks:add(util.table_delimiter(row:get(), 13, { 5, 5 }))

        marks:add(indent(row:inc(), l1))
        marks:add(indent(row:inc(), l1))
        marks:extend(util.heading(row:get(), 1))
        marks:add(indent(row:inc(), l1))

        marks:add(indent(row:inc(), l1))

        marks:add(indent(row:inc(), l1))
        marks:add(indent(row:get(), l2))
        marks:add(indent(row:inc(), l1))
        marks:add(indent(row:get(), l2))
        marks:extend(util.heading(row:get(), 3))
        marks:add(indent(row:inc(), l1))
        marks:add(indent(row:get(), l2))

        marks:add(indent(row:inc(), l1))
        marks:add(indent(row:get(), l2))

        util.assert_view(marks, {
            '󰫎   1 ▎   ▎    󰲣 Heading 2',
            '    2 ▎   ▎',
            '      ▎   ▎   ┌─────┬─────┐',
            '    3 ▎   ▎   │ Foo │ Bar │',
            '    4 ▎   ▎   ├─────┼─────┤',
            '    5 ▎',
            '󰫎   6 ▎   󰲡 Heading 1',
            '    7 ▎',
            '    8 ▎   Foo',
            '    9 ▎   ▎   ▎',
            '󰫎  10 ▎   ▎   ▎     󰲥 Heading 3',
            '   11 ▎   ▎   ▎',
            '   12 ▎   ▎   ▎   Bar',
        })
    end)
end)
