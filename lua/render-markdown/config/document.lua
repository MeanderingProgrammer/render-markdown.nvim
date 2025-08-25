---@class (exact) render.md.document.Config: render.md.base.Config
---@field conceal render.md.document.conceal.Config

---@class (exact) render.md.document.conceal.Config
---@field char_patterns string[]
---@field line_patterns string[]

---@class render.md.document.Cfg
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

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        conceal = {
            record = {
                char_patterns = { list = { type = 'string' } },
                line_patterns = { list = { type = 'string' } },
            },
        },
    })
end

return M
