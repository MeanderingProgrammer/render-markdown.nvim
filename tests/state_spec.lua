---@module 'luassert'

local state = require('render-markdown.state')

---@param opts? render.md.UserConfig
---@return string[]
local function validate(opts)
    require('render-markdown').setup(opts)
    return state.validate()
end

describe('state', function()
    it('valid', function()
        assert.are.same(0, #validate())
        vim.bo.buftype = ''
        assert.are.same(true, state.get(0).sign.enabled)
        state.invalidate_cache()
        vim.bo.buftype = 'nofile'
        assert.are.same(false, state.get(0).sign.enabled)

        assert.are.same(0, #validate({
            callout = {
                note = { raw = 'value' },
                new = { raw = 'value', rendered = 'value', highlight = 'value' },
            },
            overrides = {
                buftype = {
                    nofile = {
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
                    },
                },
            },
        }))
    end)

    it('extra', function()
        assert.are.same(
            {
                'render-markdown.additional: is not a valid key',
                'render-markdown.anti_conceal.ignore.additional: is not a valid key',
                'render-markdown.callout.note.additional: is not a valid key',
                'render-markdown.checkbox.checked.additional: is not a valid key',
                'render-markdown.latex.additional: is not a valid key',
                'render-markdown.overrides.additional: is not a valid key',
                'render-markdown.overrides.buftype.nofile.additional: is not a valid key',
            },
            validate({
                additional = true,
                anti_conceal = { ignore = { additional = true } },
                callout = { note = { additional = true } },
                checkbox = { checked = { additional = true } },
                latex = { additional = true },
                overrides = { additional = true, buftype = { nofile = { additional = true } } },
            })
        )
    end)

    it('type', function()
        ---@diagnostic disable: assign-type-mismatch
        assert.are.same(
            {
                'render-markdown.anti_conceal.ignore.sign: expected string list or type boolean or nil, got string',
                'render-markdown.callout.a.highlight: expected type string, got nil',
                'render-markdown.callout.b: expected type table, got string',
                'render-markdown.checkbox.checked: expected type table, got boolean',
                'render-markdown.checkbox.unchecked.icon: expected type string, got boolean',
                'render-markdown.debounce: expected type number, got table',
                'render-markdown.enabled: expected type boolean, got string',
                'render-markdown.heading.enabled: expected type boolean, got string',
                'render-markdown.log_level: expected one of { "off", "debug", "info", "error" }, got string',
                'render-markdown.log_runtime: expected type boolean, got string',
                'render-markdown.max_file_size: expected type number, got boolean',
                'render-markdown.overrides.buftype.nofile.sign.highlight: expected type string or nil, got boolean',
                'render-markdown.overrides.buftype.other: expected type table, got boolean',
                'render-markdown.overrides.filetype: expected type table, got string',
                'render-markdown.padding.highlight: expected type string, got boolean',
                'render-markdown.preset: expected one of { "none", "lazy", "obsidian" }, got string',
                'render-markdown.render_modes: expected string list or type boolean, got string',
            },
            validate({
                anti_conceal = { ignore = { sign = 'invalid' } },
                callout = {
                    a = { raw = 'value', rendered = 'value' },
                    b = 'invalid',
                },
                checkbox = { checked = false, unchecked = { icon = false } },
                debounce = {},
                enabled = 'invalid',
                heading = { enabled = 'invalid' },
                log_level = 'invalid',
                log_runtime = 'invalid',
                max_file_size = true,
                overrides = {
                    buftype = {
                        nofile = { sign = { highlight = false } },
                        other = false,
                    },
                    filetype = 'invalid',
                },
                padding = { highlight = true },
                preset = 'invalid',
                render_modes = 'invalid',
            })
        )

        assert.are.same(
            {
                'render-markdown.checkbox: expected type table, got string',
                'render-markdown.render_modes: expected string list or type boolean, got table, info: [1] is number',
            },
            validate({
                checkbox = 'invalid',
                render_modes = { 1, 2 },
            })
        )
    end)
end)
