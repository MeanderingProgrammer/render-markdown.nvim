---@module 'luassert'

local util = require('tests.util')
local eq = assert.are.same

describe('state', function()
    it('validate', function()
        local base_prefix = 'render-markdown'

        eq(0, #util.validate())

        eq({ base_prefix .. '.additional: is not a valid key' }, util.validate({ additional = true }))

        eq(
            { base_prefix .. '.enabled: expected boolean, got string' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            util.validate({ enabled = 'invalid' })
        )

        eq(
            { base_prefix .. '.log_level: expected one of { "debug", "error" } or type {}, got invalid' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            util.validate({ log_level = 'invalid' })
        )

        eq(
            { base_prefix .. '.render_modes: expected string array, got true' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            util.validate({ render_modes = true })
        )

        ---@diagnostic disable-next-line: assign-type-mismatch
        local errors = util.validate({ render_modes = { 1, 2 } })
        eq(1, #errors)
        eq(true, vim.startswith(errors[1], base_prefix .. '.render_modes: expected string array, got '))
        eq(true, vim.endswith(errors[1], 'Info: Index 1 is number'))

        eq(0, #util.validate({ callout = { note = { raw = 'value' } } }))

        eq(
            { base_prefix .. '.callout.note.additional: is not a valid key' },
            util.validate({ callout = { note = { additional = true } } })
        )

        eq(0, #util.validate({ callout = { new = { raw = 'value', rendered = 'value', highlight = 'value' } } }))

        eq(
            { base_prefix .. '.callout.new.highlight: expected string, got nil' },
            util.validate({ callout = { new = { raw = 'value', rendered = 'value' } } })
        )

        eq({ base_prefix .. '.latex.additional: is not a valid key' }, util.validate({ latex = { additional = true } }))

        local over_prefix = base_prefix .. '.overrides.buftype.nofile'
        ---@param opts render.md.UserBufferConfig
        ---@return string[]
        local function validate_over(opts)
            return util.validate({ overrides = { buftype = { nofile = opts } } })
        end

        eq(
            { over_prefix .. '.sign.highlight: expected string, got boolean' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            validate_over({ sign = { highlight = false } })
        )
        eq(0, #validate_over({
            enabled = false,
            max_file_size = 0,
            render_modes = {},
            anti_conceal = {},
            heading = {},
            code = {},
            dash = {},
            bullet = {},
            checkbox = { unchecked = {}, checked = {} },
            quote = {},
            pipe_table = {},
            callout = {},
            link = {},
            sign = {},
            win_options = {},
        }))
    end)
end)
