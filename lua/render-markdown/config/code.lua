---@class (exact) render.md.code.Config: render.md.base.Config
---@field sign boolean
---@field style render.md.code.Style
---@field position render.md.code.Position
---@field language_pad number
---@field language_icon boolean
---@field language_name boolean
---@field disable_background boolean|string[]
---@field width render.md.code.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field border render.md.code.Border
---@field above string
---@field below string
---@field inline_left string
---@field inline_right string
---@field inline_pad integer
---@field highlight string
---@field highlight_language? string
---@field highlight_border false|string
---@field highlight_fallback string
---@field highlight_inline string

---@enum render.md.code.Style
local Style = {
    full = 'full',
    normal = 'normal',
    language = 'language',
    none = 'none',
}

---@enum render.md.code.Position
local Position = {
    left = 'left',
    right = 'right',
}

---@enum render.md.code.Width
local Width = {
    full = 'full',
    block = 'block',
}

---@enum render.md.code.Border
local Border = {
    hide = 'hide',
    thin = 'thin',
    thick = 'thick',
    none = 'none',
}

---@class render.md.code.Cfg
local M = {}

---@type render.md.code.Config
M.default = {
    -- Turn on / off code block & inline code rendering.
    enabled = true,
    -- Additional modes to render code blocks.
    render_modes = false,
    -- Turn on / off any sign column related rendering.
    sign = true,
    -- Determines how code blocks & inline code are rendered.
    -- | none     | disables all rendering                                                    |
    -- | normal   | highlight group to code blocks & inline code, adds padding to code blocks |
    -- | language | language icon to sign column if enabled and icon + name above code blocks |
    -- | full     | normal + language                                                         |
    style = 'full',
    -- Determines where language icon is rendered.
    -- | right | right side of code block |
    -- | left  | left side of code block  |
    position = 'left',
    -- Amount of padding to add around the language.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    language_pad = 0,
    -- Whether to include the language icon above code blocks.
    language_icon = true,
    -- Whether to include the language name above code blocks.
    language_name = true,
    -- A list of language names for which background highlighting will be disabled.
    -- Likely because that language has background highlights itself.
    -- Use a boolean to make behavior apply to all languages.
    -- Borders above & below blocks will continue to be rendered.
    disable_background = { 'diff' },
    -- Width of the code block background.
    -- | block | width of the code block  |
    -- | full  | full width of the window |
    width = 'full',
    -- Amount of margin to add to the left of code blocks.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Margin available space is computed after accounting for padding.
    left_margin = 0,
    -- Amount of padding to add to the left of code blocks.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    left_pad = 0,
    -- Amount of padding to add to the right of code blocks when width is 'block'.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    right_pad = 0,
    -- Minimum width to use for code blocks when width is 'block'.
    min_width = 0,
    -- Determines how the top / bottom of code block are rendered.
    -- | none  | do not render a border                               |
    -- | thick | use the same highlight as the code body              |
    -- | thin  | when lines are empty overlay the above & below icons |
    -- | hide  | conceal lines unless language name or icon is added  |
    border = 'hide',
    -- Used above code blocks for thin border.
    above = '▄',
    -- Used below code blocks for thin border.
    below = '▀',
    -- Icon to add to the left of inline code.
    inline_left = '',
    -- Icon to add to the right of inline code.
    inline_right = '',
    -- Padding to add to the left & right of inline code.
    inline_pad = 0,
    -- Highlight for code blocks.
    highlight = 'RenderMarkdownCode',
    -- Highlight for language, overrides icon provider value.
    highlight_language = nil,
    -- Highlight for border, use false to add no highlight.
    highlight_border = 'RenderMarkdownCodeBorder',
    -- Highlight for language, used if icon provider does not have a value.
    highlight_fallback = 'RenderMarkdownCodeFallback',
    -- Highlight for inline code.
    highlight_inline = 'RenderMarkdownCodeInline',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('sign', 'boolean')
    spec:one_of('style', vim.tbl_values(Style))
    spec:one_of('position', vim.tbl_values(Position))
    spec:type('language_pad', 'number')
    spec:type('language_icon', 'boolean')
    spec:type('language_name', 'boolean')
    spec:list('disable_background', 'string', 'boolean')
    spec:one_of('width', vim.tbl_values(Width))
    spec:type('left_margin', 'number')
    spec:type('left_pad', 'number')
    spec:type('right_pad', 'number')
    spec:type('min_width', 'number')
    spec:one_of('border', vim.tbl_values(Border))
    spec:type('above', 'string')
    spec:type('below', 'string')
    spec:type('inline_left', 'string')
    spec:type('inline_right', 'string')
    spec:type('inline_pad', 'number')
    spec:type('highlight', 'string')
    spec:type('highlight_language', { 'string', 'nil' })
    spec:one_of('highlight_border', { false }, 'string')
    spec:type('highlight_fallback', 'string')
    spec:type('highlight_inline', 'string')
    spec:check()
end

return M
