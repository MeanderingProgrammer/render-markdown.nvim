---@class (exact) render.md.paragraph.Config: render.md.base.Config
---@field left_margin number
---@field min_width integer

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('left_margin', 'number')
    spec:type('min_width', 'number')
    spec:check()
end

return M
