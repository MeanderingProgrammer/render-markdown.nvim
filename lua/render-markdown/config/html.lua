---@class (exact) render.md.html.Config: render.md.base.Config
---@field comment render.md.html.comment.Config
---@field tag table<string, render.md.html.Tag>

---@class (exact) render.md.html.comment.Config
---@field conceal boolean
---@field text? string
---@field highlight string

---@class (exact) render.md.html.Tag
---@field icon? string
---@field highlight? string
---@field scope_highlight? string

---@class render.md.html.Cfg
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
    -- | icon            | optional icon inlined at start of tag           |
    -- | highlight       | optional highlight for the icon                 |
    -- | scope_highlight | optional highlight for item associated with tag |
    tag = {},
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local tag = {
        record = {
            icon = { optional = true, type = 'string' },
            highlight = { optional = true, type = 'string' },
            scope_highlight = { optional = true, type = 'string' },
        },
    }
    return require('render-markdown.config.base').schema({
        comment = {
            record = {
                conceal = { type = 'boolean' },
                text = { optional = true, type = 'string' },
                highlight = { type = 'string' },
            },
        },
        tag = { map = { { type = 'string' }, tag } },
    })
end

return M
