---@class (exact) render.md.html.Config: render.md.base.Config
---@field comment render.md.html.comment.Config
---@field tag table<string, render.md.html.Tag>

---@class (exact) render.md.html.comment.Config
---@field conceal boolean
---@field text? string
---@field highlight string

---@class (exact) render.md.html.Tag
---@field icon string
---@field highlight string

---@class render.md.html
local M = {}

---@type render.md.html.Config
M.default = {
    -- Turn on / off all HTML rendering.
    enabled = true,
    -- Additional modes to render HTML.
    render_modes = false,
    comment = {
        -- Turn on / off HTML comment concealing.
        conceal = true,
        -- Optional text to inline before the concealed comment.
        text = nil,
        -- Highlight for the inlined text.
        highlight = 'RenderMarkdownHtmlComment',
    },
    -- HTML tags whose start and end will be hidden and icon shown.
    -- The key is matched against the tag name, value type below.
    -- | icon      | gets inlined at the start |
    -- | highlight | highlight for the icon    |
    tag = {},
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:nested('comment', function(comment)
        comment:type('conceal', 'boolean')
        comment:type('text', { 'string', 'nil' })
        comment:type('highlight', 'string')
        comment:check()
    end)
    spec:nested('tag', function(tags)
        tags:each(function(tag)
            tag:type('icon', 'string')
            tag:type('highlight', 'string')
            tag:check()
        end, false)
        tags:check()
    end)
    spec:check()
end

return M
