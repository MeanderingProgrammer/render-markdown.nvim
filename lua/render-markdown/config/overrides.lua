---@class (exact) render.md.overrides.Config
---@field buflisted table<boolean, render.md.partial.UserConfig>
---@field buftype table<string, render.md.partial.UserConfig>
---@field filetype table<string, render.md.partial.UserConfig>

---@class render.md.overrides.Cfg
local M = {}

---@type render.md.overrides.Config
M.default = {
    -- More granular configuration mechanism, allows different aspects of buffers to have their own
    -- behavior. Values default to the top level configuration if no override is provided. Supports
    -- the following fields:
    --   enabled, max_file_size, debounce, render_modes, anti_conceal, padding, heading, paragraph,
    --   code, dash, bullet, checkbox, quote, pipe_table, callout, link, sign, indent, latex, html,
    --   win_options

    -- Override for different buflisted values, @see :h 'buflisted'.
    buflisted = {},
    -- Override for different buftype values, @see :h 'buftype'.
    buftype = {
        nofile = {
            render_modes = true,
            padding = { highlight = 'NormalFloat' },
            sign = { enabled = false },
        },
    },
    -- Override for different filetype values, @see :h 'filetype'.
    filetype = {},
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    local Config = require('render-markdown.lib.config')
    spec:nested({ 'buflisted', 'buftype', 'filetype' }, function(overrides)
        overrides:each(function(override)
            Config.validate(override)
            override:check()
        end, true)
        overrides:check()
    end)
    spec:check()
end

return M
