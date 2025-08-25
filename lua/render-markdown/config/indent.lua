---@class (exact) render.md.indent.Config: render.md.base.Config
---@field per_level integer
---@field skip_level integer
---@field skip_heading boolean
---@field icon string
---@field priority integer
---@field highlight string

---@class render.md.indent.Cfg
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
    -- Priority to assign to extmarks.
    priority = 0,
    -- Applied to icon.
    highlight = 'RenderMarkdownIndent',
}

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        per_level = { type = 'number' },
        skip_level = { type = 'number' },
        skip_heading = { type = 'boolean' },
        icon = { type = 'string' },
        priority = { type = 'number' },
        highlight = { type = 'string' },
    })
end

return M
