---@class (exact) render.md.heading.Config: render.md.base.Config
---@field atx boolean
---@field setext boolean
---@field sign boolean
---@field icons render.md.heading.Icons
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

---@alias render.md.heading.Icons
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

---@class render.md.heading
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
    -- Turn on / off any sign column related rendering.
    sign = true,
    -- Replaces '#+' of 'atx_h._marker'.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)`              |
    -- | string[] | `cycle(value, context.level)` |
    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Determines how icons fill the available space.
    -- | right   | '#'s are concealed and icon is appended to right side                          |
    -- | inline  | '#'s are concealed and icon is inlined on left side                            |
    -- | overlay | icon is left padded with spaces and inserted on left hiding any additional '#' |
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

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('atx', 'boolean')
    spec:type('setext', 'boolean')
    spec:type('sign', 'boolean')
    spec:list('icons', 'string', 'function')
    spec:one_of('position', vim.tbl_values(Position))
    spec:list('signs', 'string')
    spec:one_or_list_of('width', vim.tbl_values(Width))
    spec:list('left_margin', 'number', 'number')
    spec:list('left_pad', 'number', 'number')
    spec:list('right_pad', 'number', 'number')
    spec:list('min_width', 'number', 'number')
    spec:list('border', 'boolean', 'boolean')
    spec:type('border_virtual', 'boolean')
    spec:type('border_prefix', 'boolean')
    spec:type('above', 'string')
    spec:type('below', 'string')
    spec:list('backgrounds', 'string')
    spec:list('foregrounds', 'string')
    spec:nested('custom', function(customs)
        customs:each(function(custom)
            custom:type('pattern', 'string')
            custom:type('icon', { 'string', 'nil' })
            custom:type('background', { 'string', 'nil' })
            custom:type('foreground', { 'string', 'nil' })
            custom:check()
        end, false)
        customs:check()
    end)
    spec:check()
end

return M
