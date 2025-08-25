---@alias render.md.window.Configs table<string, render.md.window.Config>

---@class (exact) render.md.window.Config
---@field default render.md.option.Value
---@field rendered render.md.option.Value

---@alias render.md.option.Value number|integer|string|boolean

---@class render.md.window.Cfg
local M = {}

---@type render.md.window.Configs
M.default = {
    -- Window options to use that change between rendered and raw view.

    -- @see :h 'conceallevel'
    conceallevel = {
        -- Used when not being rendered, get user setting.
        default = vim.o.conceallevel,
        -- Used when being rendered, concealed text is completely hidden.
        rendered = 3,
    },
    -- @see :h 'concealcursor'
    concealcursor = {
        -- Used when not being rendered, get user setting.
        default = vim.o.concealcursor,
        -- Used when being rendered, show concealed text in all modes.
        rendered = '',
    },
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local value = {
        union = {
            { type = 'number' },
            { type = 'string' },
            { type = 'boolean' },
        },
    }
    ---@type render.md.Schema
    local option = { record = { default = value, rendered = value } }
    ---@type render.md.Schema
    return { map = { key = { type = 'string' }, value = option } }
end

return M
