---@module 'luassert'

local util = require('tests.util')

describe('checkbox', function()
    it('handle nested list items', function()
        util.setup.text({
            '1.  -  [x]  Checked Checkbox',
            '1.  -  [-]  Todo Checkbox',
        })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 4 }, util.ordered(1))
        marks:add({ 0, 0 }, { 4, 7 }, util.conceal())
        marks:add(0, 7, util.checkbox('checked', 1))
        marks:add({ 0, 0 }, { 10, 11 }, util.conceal())
        marks:add({ 1, 1 }, { 0, 4 }, util.ordered(2))
        marks:add({ 1, 1 }, { 4, 7 }, util.conceal())
        marks:add(1, 7, util.checkbox('todo', 0))
        marks:add(1, 11, util.padding(1, false))
        util.assert_view(marks, {
            '1.  󰱒   Checked Checkbox',
            '2.  󰥔   Todo Checkbox',
        })
    end)

    it('ignores invalid position', function()
        util.setup.text({
            '- Todo [-] Checkbox',
        })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 2 }, util.bullet(1))
        util.assert_view(marks, {
            '● Todo - Checkbox',
        })
    end)
end)
