---@module 'luassert'

local util = require('tests.util')

local lines = {
    '',
    '## Heading 2',
    '',
    '| Foo | Bar |',
    '| --- | --- |',
    '',
    '# Heading 1',
    '',
    'Foo',
    '',
    '### Heading 3',
    '',
    'Bar',
}

---@return render.md.test.Marks
local function shared()
    local marks, row = util.marks(), util.row()

    marks:add(row:get(1), 0, util.heading.sign(2))
    marks:add(row:get(0, 0), { 0, 2 }, util.heading.icon(2))
    marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(2))

    marks:add(row:get(1, 0), { 0, 1 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 6, 7 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 12, 13 }, util.table.pipe(true))
    marks:add(row:get(1, 0), { 0, 13 }, util.table.delimiter(0, { 5 }, { 5 }))

    marks:add(row:get(2), 0, util.heading.sign(1))
    marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
    marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

    marks:add(row:get(3), 0, util.heading.sign(3))
    marks:add(row:get(0, 0), { 0, 3 }, util.heading.icon(3))
    marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(3))

    return marks
end

---@return render.md.test.Marks
local function borders()
    ---@param level integer
    ---@param position 'above'|'below'
    ---@return vim.api.keyset.set_extmark
    local function border(level, position)
        local icon = position == 'above' and '▄' or '▀'
        local background = ('Rm_RmH%dBg_bg_as_fg'):format(level)
        ---@type vim.api.keyset.set_extmark
        return {
            virt_text = { { icon:rep(vim.o.columns), background } },
            virt_text_pos = 'overlay',
        }
    end

    local marks, row = util.marks(), util.row()

    marks:add(row:get(0), 0, border(2, 'above'))
    marks:add(row:get(2), 0, border(2, 'below'))

    marks:add(row:get(3), 0, border(1, 'above'))
    marks:add(row:get(2), 0, border(1, 'below'))

    marks:add(row:get(2), 0, border(3, 'above'))
    marks:add(row:get(2), 0, border(3, 'below'))

    return marks
end

describe('indent', function()
    it('with heading border & no icon', function()
        util.setup.text(lines, {
            heading = { border = true },
            indent = { enabled = true, icon = '' },
        })

        local marks, row = shared(), util.row()
        marks:extend(borders())

        local l2, l3 = { 2 }, { 4 }

        marks:add(row:get(0), 0, util.indent.inline(l2))
        marks:add(row:get(1), 0, util.indent.inline(l2))
        marks:add(row:get(1), 0, util.indent.inline(l2))

        marks:add(
            row:get(1),
            0,
            util.indent.virtual(util.table.border(true, true, 5, 5), l2)
        )
        marks:add(row:get(0), 0, util.indent.inline(l2))
        marks:add(row:get(1), 0, util.indent.inline(l2))

        marks:add(row:get(5), 0, util.indent.inline(l3))
        marks:add(row:get(1), 0, util.indent.inline(l3))
        marks:add(row:get(1), 0, util.indent.inline(l3))
        marks:add(row:get(1), 0, util.indent.inline(l3))

        util.assert_view(marks, {
            '    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎    󰲣 Heading 2',
            '    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '    ┌─────┬─────┐',
            '    │ Foo │ Bar │',
            '    ├─────┼─────┤',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎 󰲡 Heading 1',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  Foo',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       󰲥 Heading 3',
            '      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '      Bar',
        })
    end)

    it('with per_level & skip_level', function()
        util.setup.text(lines, {
            indent = { enabled = true, per_level = 4, skip_level = 0 },
        })

        local marks, row = shared(), util.row()

        local l1, l2 = { 1, 3 }, { 1, 3, 1, 3 }

        marks:add(row:get(0), 0, util.indent.inline(l2))
        marks:add(row:get(1), 0, util.indent.inline(l2))
        marks:add(row:get(1), 0, util.indent.inline(l2))

        marks:add(
            row:get(1),
            0,
            util.indent.virtual(util.table.border(true, true, 5, 5), l2)
        )
        marks:add(row:get(0), 0, util.indent.inline(l2))
        marks:add(row:get(1), 0, util.indent.inline(l2))

        for _ = 1, 4 do
            marks:add(row:get(1), 0, util.indent.inline(l1))
        end

        for _ = 1, 4 do
            marks:add(row:get(1), 0, util.indent.inline(l1))
            marks:add(row:get(0), 0, util.indent.inline(l2))
        end

        util.assert_view(marks, {
            '  ▎   ▎',
            '󰫎 ▎   ▎    󰲣 Heading 2',
            '  ▎   ▎',
            '  ▎   ▎   ┌─────┬─────┐',
            '  ▎   ▎   │ Foo │ Bar │',
            '  ▎   ▎   ├─────┼─────┤',
            '  ▎',
            '󰫎 ▎   󰲡 Heading 1',
            '  ▎',
            '  ▎   Foo',
            '  ▎   ▎   ▎',
            '󰫎 ▎   ▎   ▎     󰲥 Heading 3',
            '  ▎   ▎   ▎',
            '  ▎   ▎   ▎   Bar',
        })
    end)
end)
