---@class (exact) render.md.yaml.Config: render.md.base.Config

---@class render.md.yaml.Cfg
local M = {}

---@type render.md.yaml.Config
M.default = {
    -- Turn on / off all yaml rendering.
    enabled = true,
    -- Additional modes to render yaml.
    render_modes = false,
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:check()
end

return M
