local state = require('render-markdown.state')
local util = require('tests.util')

local eq = assert.are.same

describe('state', function()
    it('validate', function()
        util.setup_only()
        eq(0, #state.validate())

        util.setup_only({ additional = true })
        eq({ 'render-markdown.additional: is not a valid key' }, state.validate())

        ---@diagnostic disable-next-line: assign-type-mismatch
        util.setup_only({ enabled = 'invalid' })
        eq({ 'render-markdown.enabled: expected boolean, got string' }, state.validate())

        ---@diagnostic disable-next-line: assign-type-mismatch
        util.setup_only({ log_level = 'invalid' })
        eq({ 'render-markdown.log_level: expected one of { "debug", "error" }, got invalid' }, state.validate())

        ---@diagnostic disable-next-line: assign-type-mismatch
        util.setup_only({ render_modes = true })
        eq({ 'render-markdown.render_modes: expected string array, got true' }, state.validate())

        ---@diagnostic disable-next-line: assign-type-mismatch
        util.setup_only({ render_modes = { 1, 2 } })
        eq(1, #state.validate())
        eq(true, vim.startswith(state.validate()[1], 'render-markdown.render_modes: expected string array, got '))
        eq(true, vim.endswith(state.validate()[1], 'Info: Index 1 is number'))

        util.setup_only({ callout = { note = { raw = 'value' } } })
        eq(0, #state.validate())

        util.setup_only({ callout = { note = { additional = true } } })
        eq({ 'render-markdown.callout.note.additional: is not a valid key' }, state.validate())

        util.setup_only({ callout = { new = { raw = 'value', rendered = 'value', highlight = 'value' } } })
        eq(0, #state.validate())

        util.setup_only({ callout = { new = { raw = 'value', rendered = 'value' } } })
        eq({ 'render-markdown.callout.new.highlight: expected string, got nil' }, state.validate())

        util.setup_only({ latex = { additional = true } })
        eq({ 'render-markdown.latex.additional: is not a valid key' }, state.validate())
    end)
end)
