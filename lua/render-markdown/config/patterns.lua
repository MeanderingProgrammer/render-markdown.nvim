---@alias render.md.pattern.Configs table<string, render.md.pattern.Config>

---@class (exact) render.md.pattern.Config
---@field disable boolean
---@field directives render.md.directive.Config[]

---@class (exact) render.md.directive.Config
---@field id integer
---@field name string

---@class render.md.pattern.Cfg
local M = {}

---@type render.md.pattern.Configs
M.default = {
    -- Highlight patterns to disable for filetypes, i.e. lines concealed around code blocks

    markdown = {
        disable = true,
        directives = {
            { id = 17, name = 'conceal_lines' },
            { id = 18, name = 'conceal_lines' },
        },
    },
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local directive = {
        record = {
            id = { type = 'number' },
            name = { type = 'string' },
        },
    }
    ---@type render.md.Schema
    local pattern = {
        record = {
            disable = { type = 'boolean' },
            directives = { list = directive },
        },
    }
    ---@type render.md.Schema
    return { map = { { type = 'string' }, pattern } }
end

return M
