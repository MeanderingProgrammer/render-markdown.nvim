---@class (exact) render.md.paragraph.Config: render.md.base.Config
---@field left_margin render.md.paragraph.Number
---@field indent render.md.paragraph.Number
---@field min_width integer

---@class (exact) render.md.paragraph.Context
---@field text string

---@alias render.md.paragraph.Number
---| number
---| fun(ctx: render.md.paragraph.Context): number

---@class render.md.paragraph.Cfg
local M = {}

---@type render.md.paragraph.Config
M.default = {
    -- Useful context to have when evaluating values.
    -- | text | text value of the node |

    -- Turn on / off paragraph rendering.
    enabled = true,
    -- Additional modes to render paragraphs.
    render_modes = false,
    -- Amount of margin to add to the left of paragraphs.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)` |
    -- | number   | `value`          |
    left_margin = 0,
    -- Amount of padding to add to the first line of each paragraph.
    -- Output is evaluated using the same logic as 'left_margin'.
    indent = 0,
    -- Minimum width to use for paragraphs.
    min_width = 0,
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    local Base = require('render-markdown.config.base')
    Base.validate(spec)
    spec:type('left_margin', { 'number', 'function' })
    spec:type('indent', { 'number', 'function' })
    spec:type('min_width', 'number')
    spec:check()
end

return M
