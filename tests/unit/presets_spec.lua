---@module 'luassert'

---@param user render.md.UserConfig
---@param expected render.md.UserConfig
local function validate(user, expected)
    local actual = require('render-markdown.lib.presets').get(user)
    assert.same(expected, actual)
end

describe('presets', function()
    it('overlap', function()
        validate({
            preset = 'lazy',
            code = { style = 'normal' },
        }, {
            file_types = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
            code = {
                sign = false,
                width = 'block',
                right_pad = 1,
                language = false,
            },
            heading = {
                sign = false,
                icons = {},
            },
            checkbox = { enabled = false },
            pipe_table = {},
            win_options = {},
            overrides = {},
        })
    end)

    it('override', function()
        validate({
            code = { style = 'none' },
            overrides = {
                buftype = {
                    nofile = {
                        code = { style = 'normal' },
                    },
                },
            },
        }, {
            code = { enabled = false },
            pipe_table = {},
            win_options = {},
            overrides = {
                buftype = {
                    nofile = {
                        code = { language = false },
                        pipe_table = {},
                        win_options = {},
                    },
                },
            },
        })
    end)
end)
