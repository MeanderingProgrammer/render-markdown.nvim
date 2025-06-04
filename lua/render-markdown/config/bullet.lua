---@class (exact) render.md.bullet.Config: render.md.base.Config
---@field icons render.md.bullet.String
---@field ordered_icons render.md.bullet.String
---@field left_pad render.md.bullet.Integer
---@field right_pad render.md.bullet.Integer
---@field highlight render.md.bullet.String
---@field scope_highlight render.md.bullet.String

---@class (exact) render.md.bullet.Context
---@field level integer
---@field index integer
---@field value string

---@alias render.md.bullet.String
---| string
---| string[]
---| string[][]
---| fun(ctx: render.md.bullet.Context): string?

---@alias render.md.bullet.Integer
---| integer
---| fun(ctx: render.md.bullet.Context): integer

---@class render.md.bullet.Cfg
local M = {}

---@type render.md.bullet.Config
M.default = {
    -- Useful context to have when evaluating values.
    -- | level | how deeply nested the list is, 1-indexed          |
    -- | index | how far down the item is at that level, 1-indexed |
    -- | value | text value of the marker node                     |

    -- Turn on / off list bullet rendering
    enabled = true,
    -- Additional modes to render list bullets
    render_modes = false,
    -- Replaces '-'|'+'|'*' of 'list_item'.
    -- If the item is a 'checkbox' a conceal is used to hide the bullet instead.
    -- Output is evaluated depending on the type.
    -- | function   | `value(context)`                                    |
    -- | string     | `value`                                             |
    -- | string[]   | `cycle(value, context.level)`                       |
    -- | string[][] | `clamp(cycle(value, context.level), context.index)` |
    icons = { '●', '○', '◆', '◇' },
    -- Replaces 'n.'|'n)' of 'list_item'.
    -- Output is evaluated using the same logic as 'icons'.
    ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ('%d.'):format(index > 1 and index or ctx.index)
    end,
    -- Padding to add to the left of bullet point.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)` |
    -- | integer  | `value`          |
    left_pad = 0,
    -- Padding to add to the right of bullet point.
    -- Output is evaluated using the same logic as 'left_pad'.
    right_pad = 0,
    -- Highlight for the bullet icon.
    -- Output is evaluated using the same logic as 'icons'.
    highlight = 'RenderMarkdownBullet',
    -- Highlight for item associated with the bullet point.
    -- Output is evaluated using the same logic as 'icons'.
    scope_highlight = {},
}

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
