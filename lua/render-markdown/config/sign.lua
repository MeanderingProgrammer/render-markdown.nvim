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

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    return {
        record = {
            enabled = { type = 'boolean' },
            highlight = { type = 'string' },
        },
    }
end

return M
