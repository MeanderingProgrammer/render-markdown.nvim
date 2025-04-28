---@class (exact) render.md.document.Config: render.md.base.Config
---@field conceal render.md.document.conceal.Config

---@class (exact) render.md.document.conceal.Config
---@field char_patterns string[]
---@field line_patterns string[]

---@class render.md.document
local M = {}

---@type render.md.document.Config
M.default = {
    -- Turn on / off document rendering.
    enabled = true,
    -- Additional modes to render document.
    render_modes = false,
    -- Ability to conceal arbitrary ranges of text based on lua patterns, @see :h lua-patterns.
    -- Relies entirely on user to set patterns that handle their edge cases.
    conceal = {
        -- Matched ranges will be concealed using character level conceal.
        char_patterns = {},
        -- Matched ranges will be concealed using line level conceal.
        line_patterns = {},
    },
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:nested('conceal', function(conceal)
        conceal:list('char_patterns', 'string')
        conceal:list('line_patterns', 'string')
        conceal:check()
    end)
    spec:check()
end

return M
