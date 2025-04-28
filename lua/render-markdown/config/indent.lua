---@class (exact) render.md.indent.Config: render.md.base.Config
---@field per_level integer
---@field skip_level integer
---@field skip_heading boolean
---@field icon string
---@field highlight string

---@class render.md.indent
local M = {}

---@type render.md.indent.Config
M.default = {
    -- Mimic org-indent-mode behavior by indenting everything under a heading based on the
    -- level of the heading. Indenting starts from level 2 headings onward by default.

    -- Turn on / off org-indent-mode.
    enabled = false,
    -- Additional modes to render indents.
    render_modes = false,
    -- Amount of additional padding added for each heading level.
    per_level = 2,
    -- Heading levels <= this value will not be indented.
    -- Use 0 to begin indenting from the very first level.
    skip_level = 1,
    -- Do not indent heading titles, only the body.
    skip_heading = false,
    -- Prefix added when indenting, one per level.
    icon = '▎',
    -- Applied to icon.
    highlight = 'RenderMarkdownIndent',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('per_level', 'number')
    spec:type('skip_level', 'number')
    spec:type('skip_heading', 'boolean')
    spec:type('icon', 'string')
    spec:type('highlight', 'string')
    spec:check()
end

return M
