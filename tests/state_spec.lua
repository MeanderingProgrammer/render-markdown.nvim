---@module 'luassert'

local state = require('render-markdown.state')

---@param config render.md.UserConfig
---@param expected string[]
local function validate(config, expected)
    require('render-markdown').setup(config)
    assert.same(expected, state.validate())
end

---@param expected any
---@param path string[]
local function option(expected, path)
    local config = state.get(0)
    assert.same(expected, vim.tbl_get(config, unpack(path)))
end

describe('state', function()
    it('default', function()
        validate({}, {})
    end)

    it('buftype override', function()
        local config = { sign = { enabled = true } }
        local path = { 'sign', 'enabled' }

        vim.bo.buftype = ''
        validate(config, {})
        option(true, path)

        vim.bo.buftype = 'nofile'
        validate(config, {})
        option(false, path)
    end)

    it('anti conceal preset', function()
        local path = { 'win_options', 'concealcursor', 'rendered' }

        validate({}, {})
        option('', path)

        validate({ anti_conceal = { enabled = true } }, {})
        option('', path)

        validate({ anti_conceal = { enabled = false } }, {})
        option('nvic', path)
    end)

    it('valid', function()
        local config = {
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
        }
        validate(config, {})
    end)

    it('extra', function()
        local config = {
            additional = true,
            anti_conceal = { ignore = { additional = true } },
            callout = { note = { additional = true } },
            checkbox = { checked = { additional = true } },
            latex = { additional = true },
            overrides = {
                additional = true,
                buftype = { nofile = { additional = true } },
            },
        }
        local expected = {
            'additional - expected: nil, got: boolean',
            'anti_conceal.ignore.additional - expected: nil, got: boolean',
            'callout.note.additional - expected: nil, got: boolean',
            'checkbox.checked.additional - expected: nil, got: boolean',
            'latex.additional - expected: nil, got: boolean',
            'overrides.additional - expected: nil, got: boolean',
            'overrides.buftype.nofile.additional - expected: nil, got: boolean',
        }
        validate(config, expected)
    end)

    it('type', function()
        local config = {
            anti_conceal = { ignore = { sign = 'invalid' } },
            bullet = { icons = 0 },
            callout = {
                a = { raw = 'value', rendered = 'value' },
                b = 'invalid',
            },
            checkbox = { checked = false, unchecked = { icon = false } },
            custom_handlers = {
                markdown = { extends = 'invalid', parse = 'invalid' },
            },
            debounce = {},
            enabled = 'invalid',
            file_types = { other = false },
            heading = { enabled = 'invalid' },
            log_level = 'invalid',
            log_runtime = 'invalid',
            max_file_size = true,
            overrides = {
                buftype = {
                    [1] = false,
                    nofile = { sign = { highlight = false } },
                    other = false,
                },
                filetype = 'invalid',
            },
            padding = { highlight = true },
            preset = 'invalid',
            render_modes = 'invalid',
        }
        local expected = {
            'anti_conceal.ignore.sign - expected: string[]|boolean, got: "invalid"',
            'bullet.icons - expected: string|string[]|string[][]|function, got: 0',
            'callout.a.highlight - expected: string, got: nil',
            'callout.b - expected: table, got: string',
            'checkbox.checked - expected: table, got: boolean',
            'checkbox.unchecked.icon - expected: string, got: boolean',
            'custom_handlers.markdown.extends - expected: boolean?, got: string',
            'custom_handlers.markdown.parse - expected: function, got: string',
            'debounce - expected: number, got: table',
            'enabled - expected: boolean, got: string',
            'file_types.other - expected: nil, got: boolean',
            'heading.enabled - expected: boolean, got: string',
            'log_level - expected: "debug"|"error"|"info"|"off"|"trace"|"warn", got: "invalid"',
            'log_runtime - expected: boolean, got: string',
            'max_file_size - expected: number, got: boolean',
            'overrides.buftype.1 - expected: nil, got: boolean',
            'overrides.buftype.nofile.sign.highlight - expected: string?, got: boolean',
            'overrides.buftype.other - expected: table?, got: boolean',
            'overrides.filetype - expected: map<string, table>?, got: string',
            'padding.highlight - expected: string, got: boolean',
            'preset - expected: "lazy"|"none"|"obsidian", got: "invalid"',
            'render_modes - expected: string[]|boolean, got: "invalid"',
        }
        validate(config, expected)
    end)

    it('value', function()
        local config = {
            checkbox = 'invalid',
            render_modes = { 1, 2 },
        }
        local expected = {
            'checkbox - expected: table, got: string',
            'render_modes - expected: string[]|boolean, got: { 1, 2 }',
        }
        validate(config, expected)
    end)
end)
