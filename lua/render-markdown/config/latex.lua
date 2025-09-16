---@class (exact) render.md.latex.Config: render.md.base.Config
---@field converter string|string[]
---@field highlight string
---@field position render.md.latex.Position
---@field top_pad integer
---@field bottom_pad integer

---@enum render.md.latex.Position
local Position = {
    above = 'above',
    below = 'below',
    center = 'center',
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
    -- If a list is provided the first command available on the system is used.
    converter = { 'utftex', 'latex2text' },
    -- Highlight for latex blocks.
    highlight = 'RenderMarkdownMath',
    -- Determines where latex formula is rendered relative to block.
    -- | above  | above latex block                               |
    -- | below  | below latex block                               |
    -- | center | centered with latex block (must be single line) |
    position = 'center',
    -- Number of empty lines above latex blocks.
    top_pad = 0,
    -- Number of empty lines below latex blocks.
    bottom_pad = 0,
}

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        converter = {
            union = { { list = { type = 'string' } }, { type = 'string' } },
        },
        highlight = { type = 'string' },
        position = { enum = Position },
        top_pad = { type = 'number' },
        bottom_pad = { type = 'number' },
    })
end

return M
