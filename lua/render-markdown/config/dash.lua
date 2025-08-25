---@class (exact) render.md.dash.Config: render.md.base.Config
---@field icon string
---@field width render.md.dash.Width
---@field left_margin number
---@field highlight string

---@alias render.md.dash.Width 'full'|number

---@class render.md.dash.Cfg
local M = {}

---@type render.md.dash.Config
M.default = {
    -- Turn on / off thematic break rendering.
    enabled = true,
    -- Additional modes to render dash.
    render_modes = false,
    -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'.
    -- The icon gets repeated across the window's width.
    icon = '─',
    -- Width of the generated line.
    -- | <number> | a hard coded width value |
    -- | full     | full width of the window |
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    width = 'full',
    -- Amount of margin to add to the left of dash.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    left_margin = 0,
    -- Highlight for the whole line generated from the icon.
    highlight = 'RenderMarkdownDash',
}

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        icon = { type = 'string' },
        width = {
            union = { { enum = { 'full' } }, { type = 'number' } },
        },
        left_margin = { type = 'number' },
        highlight = { type = 'string' },
    })
end

return M
