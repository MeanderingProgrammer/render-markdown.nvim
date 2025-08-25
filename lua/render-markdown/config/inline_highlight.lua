---@class (exact) render.md.inline.highlight.Config: render.md.base.Config
---@field highlight string

---@class render.md.inline.highlight.Cfg
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

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        highlight = { type = 'string' },
    })
end

return M
