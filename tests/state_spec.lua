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
                'render-markdown.additional - invalid key',
                'render-markdown.anti_conceal.ignore.additional - invalid key',
                'render-markdown.callout.note.additional - invalid key',
                'render-markdown.checkbox.checked.additional - invalid key',
                'render-markdown.latex.additional - invalid key',
                'render-markdown.overrides.additional - invalid key',
                'render-markdown.overrides.buftype.nofile.additional - invalid key',
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
                'render-markdown.anti_conceal.ignore.sign - expected: string[] or boolean or nil, but got: string',
                'render-markdown.bullet.icons - expected: string or string[] or string[][] or function, but got: number',
                'render-markdown.callout.a.highlight - expected: string, but got: nil',
                'render-markdown.callout.b - expected: table, but got: string',
                'render-markdown.checkbox.checked - expected: table, but got: boolean',
                'render-markdown.checkbox.unchecked.icon - expected: string, but got: boolean',
                'render-markdown.debounce - expected: number, but got: table',
                'render-markdown.enabled - expected: boolean, but got: string',
                'render-markdown.heading.enabled - expected: boolean, but got: string',
                'render-markdown.log_level - expected: "off" or "debug" or "info" or "error", but got: "invalid"',
                'render-markdown.log_runtime - expected: boolean, but got: string',
                'render-markdown.max_file_size - expected: number, but got: boolean',
                'render-markdown.overrides.buftype.nofile.sign.highlight - expected: string or nil, but got: boolean',
                'render-markdown.overrides.buftype.other - expected: table, but got: boolean',
                'render-markdown.overrides.filetype - expected: table, but got: string',
                'render-markdown.padding.highlight - expected: string, but got: boolean',
                'render-markdown.preset - expected: "none" or "lazy" or "obsidian", but got: "invalid"',
                'render-markdown.render_modes - expected: string[] or boolean, but got: string',
            },
            validate({
                anti_conceal = { ignore = { sign = 'invalid' } },
                bullet = { icons = 0 },
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
                'render-markdown.checkbox - expected: table, but got: string',
                'render-markdown.render_modes - expected: string[] or boolean, but got: table, info: [1] is number',
            },
            validate({
                checkbox = 'invalid',
                render_modes = { 1, 2 },
            })
        )
    end)
end)
