---@class (exact) render.md.paragraph.Config: render.md.base.Config
---@field left_margin render.md.paragraph.Margin
---@field min_width integer

---@class (exact) render.md.paragraph.Context
---@field text string

---@alias render.md.paragraph.Margin
---| number
---| fun(ctx: render.md.paragraph.Context): number

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('left_margin', { 'number', 'function' })
    spec:type('min_width', 'number')
    spec:check()
end

return M
