---@class (exact) render.md.latex.Config: render.md.base.Config
---@field converter string
---@field highlight string
---@field position render.md.latex.Position
---@field top_pad integer
---@field bottom_pad integer

---@enum (key) render.md.latex.Position
local Position = {
    above = 'above',
    below = 'below',
}

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('converter', 'string')
        :type('highlight', 'string')
        :one_of('position', vim.tbl_keys(Position))
        :type('top_pad', 'number')
        :type('bottom_pad', 'number')
        :check()
end

return M
