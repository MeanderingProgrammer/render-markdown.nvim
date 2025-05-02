---@class (exact) render.md.sign.Config
---@field enabled boolean
---@field highlight string

---@class render.md.sign.Cfg
local M = {}

---@type render.md.sign.Config
M.default = {
    -- Turn on / off sign rendering.
    enabled = true,
    -- Applies to background of sign text.
    highlight = 'RenderMarkdownSign',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('enabled', 'boolean')
    spec:type('highlight', 'string')
    spec:check()
end

return M
