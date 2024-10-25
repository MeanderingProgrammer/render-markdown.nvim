---@module 'luassert'

local state = require('render-markdown.state')
local eq = assert.are.same

---@param opts? render.md.UserConfig
---@return string[]
local function validate(opts)
    require('render-markdown').setup(opts)
    return state.validate()
end

---@param opts render.md.UserBufferConfig
---@return string[]
local function validate_override(opts)
    return validate({ overrides = { buftype = { nofile = opts } } })
end

local prefix = 'render-markdown'
local override_prefix = prefix .. '.overrides.buftype.nofile'

describe('state', function()
    it('valid', function()
        eq(0, #validate())
        vim.bo.buftype = ''
        eq(true, state.get(0).sign.enabled)
        state.invalidate_cache()
        vim.bo.buftype = 'nofile'
        eq(false, state.get(0).sign.enabled)

        eq(0, #validate({ callout = { note = { raw = 'value' } } }))

        eq(0, #validate({ callout = { new = { raw = 'value', rendered = 'value', highlight = 'value' } } }))

        eq(0, #validate_override({
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

    it('extra', function()
        eq({ prefix .. '.additional: is not a valid key' }, validate({ additional = true }))

        eq(
            { prefix .. '.callout.note.additional: is not a valid key' },
            validate({ callout = { note = { additional = true } } })
        )

        eq({ prefix .. '.latex.additional: is not a valid key' }, validate({ latex = { additional = true } }))
    end)

    it('type', function()
        eq(
            { prefix .. '.enabled: expected boolean, got string' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            validate({ enabled = 'invalid' })
        )

        eq(
            { prefix .. '.log_level: expected one of { "debug", "info", "error" }, got invalid' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            validate({ log_level = 'invalid' })
        )

        eq(
            { prefix .. '.render_modes: expected string list or type { "boolean" }, got invalid' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            validate({ render_modes = 'invalid' })
        )

        local int_render_modes = { 1, 2 }
        eq({
            prefix
                .. '.render_modes: expected string list or type { "boolean" }, got '
                .. tostring(int_render_modes)
                .. '. Info: [1] is number',
        }, validate({ render_modes = int_render_modes }))

        eq(
            { prefix .. '.callout.new.highlight: expected string, got nil' },
            validate({ callout = { new = { raw = 'value', rendered = 'value' } } })
        )

        eq(
            { override_prefix .. '.sign.highlight: expected string, got boolean' },
            ---@diagnostic disable-next-line: assign-type-mismatch
            validate_override({ sign = { highlight = false } })
        )
    end)
end)
