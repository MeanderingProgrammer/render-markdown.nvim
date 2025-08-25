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

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({})
end

return M
