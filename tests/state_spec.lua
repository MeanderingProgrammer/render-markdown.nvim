---@module 'luassert'

local util = require('tests.util')

local eq = assert.are.same

describe('state', function()
    it('validate', function()
        eq(0, #util.validate())

        eq({ 'render-markdown.additional: is not a valid key' }, util.validate({ additional = true }))

        ---@diagnostic disable-next-line: assign-type-mismatch
        eq({ 'render-markdown.enabled: expected boolean, got string' }, util.validate({ enabled = 'invalid' }))

        eq(
            { 'render-markdown.log_level: expected one of { "debug", "error" }, got invalid' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            util.validate({ log_level = 'invalid' })
        )

        ---@diagnostic disable-next-line: assign-type-mismatch
        eq({ 'render-markdown.render_modes: expected string array, got true' }, util.validate({ render_modes = true }))

        ---@diagnostic disable-next-line: assign-type-mismatch
        local errors = util.validate({ render_modes = { 1, 2 } })
        eq(1, #errors)
        eq(true, vim.startswith(errors[1], 'render-markdown.render_modes: expected string array, got '))
        eq(true, vim.endswith(errors[1], 'Info: Index 1 is number'))

        eq(0, #util.validate({ callout = { note = { raw = 'value' } } }))

        eq(
            { 'render-markdown.callout.note.additional: is not a valid key' },
            util.validate({ callout = { note = { additional = true } } })
        )

        eq(0, #util.validate({ callout = { new = { raw = 'value', rendered = 'value', highlight = 'value' } } }))

        eq(
            { 'render-markdown.callout.new.highlight: expected string, got nil' },
            util.validate({ callout = { new = { raw = 'value', rendered = 'value' } } })
        )

        eq({ 'render-markdown.latex.additional: is not a valid key' }, util.validate({ latex = { additional = true } }))
    end)
end)
