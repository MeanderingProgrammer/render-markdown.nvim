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

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        converter = { type = 'string' },
        highlight = { type = 'string' },
        position = { enum = Position },
        top_pad = { type = 'number' },
        bottom_pad = { type = 'number' },
        virtual = { type = 'boolean' },
    })
end

return M
