---@class (exact) render.md.padding.Config
---@field highlight string

---@class render.md.padding
local M = {}

---@type render.md.padding.Config
M.default = {
    -- Highlight to use when adding whitespace, should match background.
    highlight = 'Normal',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('highlight', 'string')
    spec:check()
end

return M
