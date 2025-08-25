---@class (exact) render.md.padding.Config
---@field highlight string

---@class render.md.padding.Cfg
local M = {}

---@type render.md.padding.Config
M.default = {
    -- Highlight to use when adding whitespace, should match background.
    highlight = 'Normal',
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    return { record = { highlight = { type = 'string' } } }
end

return M
