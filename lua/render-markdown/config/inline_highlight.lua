---@class (exact) render.md.inline.highlight.Config: render.md.base.Config
---@field highlight string

---@class render.md.inline.highlight
local M = {}

---@type render.md.inline.highlight.Config
M.default = {
    -- Mimics Obsidian inline highlights when content is surrounded by double equals.
    -- The equals on both ends are concealed and the inner content is highlighted.

    -- Turn on / off inline highlight rendering.
    enabled = true,
    -- Additional modes to render inline highlights.
    render_modes = false,
    -- Applies to background of surrounded text.
    highlight = 'RenderMarkdownInlineHighlight',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    local Base = require('render-markdown.config.base')
    Base.validate(spec)
    spec:type('highlight', 'string')
    spec:check()
end

return M
