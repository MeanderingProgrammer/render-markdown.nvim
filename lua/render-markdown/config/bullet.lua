---@class (exact) render.md.bullet.Config: render.md.base.Config
---@field icons render.md.bullet.Text
---@field ordered_icons render.md.bullet.Text
---@field left_pad render.md.bullet.Int
---@field right_pad render.md.bullet.Int
---@field highlight render.md.bullet.Text
---@field scope_highlight render.md.bullet.Text

---@class (exact) render.md.bullet.Context
---@field level integer
---@field index integer
---@field value string

---@alias render.md.bullet.Text
---| string
---| string[]
---| string[][]
---| fun(ctx: render.md.bullet.Context): string?

---@alias render.md.bullet.Int
---| integer
---| fun(ctx: render.md.bullet.Context): integer

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:nested_list('icons', 'string', 'function')
    spec:nested_list('ordered_icons', 'string', 'function')
    spec:type('left_pad', { 'number', 'function' })
    spec:type('right_pad', { 'number', 'function' })
    spec:nested_list('highlight', 'string', 'function')
    spec:nested_list('scope_highlight', 'string', 'function')
    spec:check()
end

return M
