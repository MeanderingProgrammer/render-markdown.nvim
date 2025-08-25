---@class (exact) render.md.heading.Config: render.md.base.Config
---@field atx boolean
---@field setext boolean
---@field sign boolean
---@field icons render.md.heading.String
---@field position render.md.heading.Position
---@field signs string[]
---@field width render.md.heading.Width|(render.md.heading.Width)[]
---@field left_margin number|number[]
---@field left_pad number|number[]
---@field right_pad number|number[]
---@field min_width integer|integer[]
---@field border boolean|boolean[]
---@field border_virtual boolean
---@field border_prefix boolean
---@field above string
---@field below string
---@field backgrounds string[]
---@field foregrounds string[]
---@field custom table<string, render.md.heading.Custom>

---@class (exact) render.md.heading.Context
---@field level integer
---@field sections integer[]

---@alias render.md.heading.String
---| string[]
---| fun(ctx: render.md.heading.Context): string?

---@enum render.md.heading.Position
local Position = {
    overlay = 'overlay',
    inline = 'inline',
    right = 'right',
}

---@enum render.md.heading.Width
local Width = {
    full = 'full',
    block = 'block',
}

---@class (exact) render.md.heading.Custom
---@field pattern string
---@field icon? string
---@field background? string
---@field foreground? string

---@class render.md.heading.Cfg
local M = {}

---@type render.md.heading.Config
M.default = {
    -- Useful context to have when evaluating values.
    -- | level    | the number of '#' in the heading marker         |
    -- | sections | for each level how deeply nested the heading is |

    -- Turn on / off heading icon & background rendering.
    enabled = true,
    -- Additional modes to render headings.
    render_modes = false,
    -- Turn on / off atx heading rendering.
    atx = true,
    -- Turn on / off setext heading rendering.
    setext = true,
    -- Turn on / off sign column related rendering.
    sign = true,
    -- Replaces '#+' of 'atx_h._marker'.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)`              |
    -- | string[] | `cycle(value, context.level)` |
    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Determines how icons fill the available space.
    -- | right   | '#'s are concealed and icon is appended to right side                      |
    -- | inline  | '#'s are concealed and icon is inlined on left side                        |
    -- | overlay | icon is left padded with spaces and inserted on left hiding additional '#' |
    position = 'overlay',
    -- Added to the sign column if enabled.
    -- Output is evaluated by `cycle(value, context.level)`.
    signs = { '󰫎 ' },
    -- Width of the heading background.
    -- | block | width of the heading text |
    -- | full  | full width of the window  |
    -- Can also be a list of the above values evaluated by `clamp(value, context.level)`.
    width = 'full',
    -- Amount of margin to add to the left of headings.
    -- Margin available space is computed after accounting for padding.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Can also be a list of numbers evaluated by `clamp(value, context.level)`.
    left_margin = 0,
    -- Amount of padding to add to the left of headings.
    -- Output is evaluated using the same logic as 'left_margin'.
    left_pad = 0,
    -- Amount of padding to add to the right of headings when width is 'block'.
    -- Output is evaluated using the same logic as 'left_margin'.
    right_pad = 0,
    -- Minimum width to use for headings when width is 'block'.
    -- Can also be a list of integers evaluated by `clamp(value, context.level)`.
    min_width = 0,
    -- Determines if a border is added above and below headings.
    -- Can also be a list of booleans evaluated by `clamp(value, context.level)`.
    border = false,
    -- Always use virtual lines for heading borders instead of attempting to use empty lines.
    border_virtual = false,
    -- Highlight the start of the border using the foreground highlight.
    border_prefix = false,
    -- Used above heading for border.
    above = '▄',
    -- Used below heading for border.
    below = '▀',
    -- Highlight for the heading icon and extends through the entire line.
    -- Output is evaluated by `clamp(value, context.level)`.
    backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
    },
    -- Highlight for the heading and sign icons.
    -- Output is evaluated using the same logic as 'backgrounds'.
    foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
    },
    -- Define custom heading patterns which allow you to override various properties based on
    -- the contents of a heading.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | pattern    | matched against the heading text @see :h lua-patterns |
    -- | icon       | optional override for the icon                        |
    -- | background | optional override for the background                  |
    -- | foreground | optional override for the foreground                  |
    custom = {},
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local custom = {
        record = {
            pattern = { type = 'string' },
            icon = { optional = true, type = 'string' },
            background = { optional = true, type = 'string' },
            foreground = { optional = true, type = 'string' },
        },
    }
    return require('render-markdown.config.base').schema({
        atx = { type = 'boolean' },
        setext = { type = 'boolean' },
        sign = { type = 'boolean' },
        icons = {
            union = { { list = { type = 'string' } }, { type = 'function' } },
        },
        position = { enum = Position },
        signs = { list = { type = 'string' } },
        width = {
            union = { { list = { enum = Width } }, { enum = Width } },
        },
        left_margin = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        left_pad = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        right_pad = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        min_width = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        border = {
            union = { { list = { type = 'boolean' } }, { type = 'boolean' } },
        },
        border_virtual = { type = 'boolean' },
        border_prefix = { type = 'boolean' },
        above = { type = 'string' },
        below = { type = 'string' },
        backgrounds = { list = { type = 'string' } },
        foregrounds = { list = { type = 'string' } },
        custom = { map = { key = { type = 'string' }, value = custom } },
    })
end

return M
