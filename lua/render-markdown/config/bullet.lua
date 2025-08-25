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

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local string_provider = {
        union = {
            { type = 'string' },
            { list = { type = 'string' } },
            { list = { list = { type = 'string' } } },
            { type = 'function' },
        },
    }
    ---@type render.md.Schema
    local integer_provider = {
        union = { { type = 'number' }, { type = 'function' } },
    }
    return require('render-markdown.config.base').schema({
        icons = string_provider,
        ordered_icons = string_provider,
        left_pad = integer_provider,
        right_pad = integer_provider,
        highlight = string_provider,
        scope_highlight = string_provider,
    })
end

return M
