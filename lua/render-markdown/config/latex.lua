---@class (exact) render.md.latex.Config: render.md.base.Config
---@field converter string
---@field highlight string
---@field position render.md.latex.Position
---@field top_pad integer
---@field bottom_pad integer
---@field virtual boolean

---@enum render.md.latex.Position
local Position = {
    above = 'above',
    below = 'below',
}

---@class render.md.latex.Cfg
local M = {}

---@type render.md.latex.Config
M.default = {
    -- Turn on / off latex rendering.
    enabled = true,
    -- Additional modes to render latex.
    render_modes = false,
    -- Executable used to convert latex formula to rendered unicode.
    converter = 'latex2text',
    -- Highlight for latex blocks.
    highlight = 'RenderMarkdownMath',
    -- Determines where latex formula is rendered relative to block.
    -- | above | above latex block |
    -- | below | below latex block |
    position = 'above',
    -- Number of empty lines above latex blocks.
    top_pad = 0,
    -- Number of empty lines below latex blocks.
    bottom_pad = 0,
    -- Always use virtual lines for rendering instead of attempting to inline.
    virtual = false,
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('converter', 'string')
    spec:type('highlight', 'string')
    spec:one_of('position', vim.tbl_values(Position))
    spec:type('top_pad', 'number')
    spec:type('bottom_pad', 'number')
    spec:type('virtual', 'boolean')
    spec:check()
end

return M
