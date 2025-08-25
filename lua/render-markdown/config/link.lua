---@class (exact) render.md.link.Config: render.md.base.Config
---@field footnote render.md.link.footnote.Config
---@field image string
---@field email string
---@field hyperlink string
---@field highlight string
---@field wiki render.md.link.wiki.Config
---@field custom table<string, render.md.link.custom.Config>

---@class (exact) render.md.link.Context
---@field buf integer
---@field row integer
---@field start_col integer
---@field end_col integer
---@field destination string
---@field alias? string

---@class (exact) render.md.link.footnote.Config
---@field enabled boolean
---@field superscript boolean
---@field prefix string
---@field suffix string

---@class (exact) render.md.link.wiki.Config
---@field icon string
---@field body fun(ctx: render.md.link.Context): render.md.mark.Text|string?
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.link.custom.Config
---@field pattern string
---@field icon string
---@field kind? render.md.link.custom.Kind
---@field priority? integer
---@field highlight? string

---@enum render.md.link.custom.Kind
local Kind = {
    pattern = 'pattern',
    suffix = 'suffix',
}

---@class render.md.link.Cfg
local M = {}

---@type render.md.link.Config
M.default = {
    -- Turn on / off inline link icon rendering.
    enabled = true,
    -- Additional modes to render links.
    render_modes = false,
    -- How to handle footnote links, start with a '^'.
    footnote = {
        -- Turn on / off footnote rendering.
        enabled = true,
        -- Replace value with superscript equivalent.
        superscript = true,
        -- Added before link content.
        prefix = '',
        -- Added after link content.
        suffix = '',
    },
    -- Inlined with 'image' elements.
    image = '󰥶 ',
    -- Inlined with 'email_autolink' elements.
    email = '󰀓 ',
    -- Fallback icon for 'inline_link' and 'uri_autolink' elements.
    hyperlink = '󰌹 ',
    -- Applies to the inlined icon as a fallback.
    highlight = 'RenderMarkdownLink',
    -- Applies to WikiLink elements.
    wiki = {
        icon = '󱗖 ',
        body = function()
            return nil
        end,
        highlight = 'RenderMarkdownWikiLink',
        scope_highlight = nil,
    },
    -- Define custom destination patterns so icons can quickly inform you of what a link
    -- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
    -- patterns match a link the one with the longer pattern is used.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | pattern   | matched against the destination text                            |
    -- | icon      | gets inlined before the link text                               |
    -- | kind      | optional determines how pattern is checked                      |
    -- |           | pattern | @see :h lua-patterns, is the default if not set       |
    -- |           | suffix  | @see :h vim.endswith()                                |
    -- | priority  | optional used when multiple match, uses pattern length if empty |
    -- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
    custom = {
        web = { pattern = '^http', icon = '󰖟 ' },
        discord = { pattern = 'discord%.com', icon = '󰙯 ' },
        github = { pattern = 'github%.com', icon = '󰊤 ' },
        gitlab = { pattern = 'gitlab%.com', icon = '󰮠 ' },
        google = { pattern = 'google%.com', icon = '󰊭 ' },
        neovim = { pattern = 'neovim%.io', icon = ' ' },
        reddit = { pattern = 'reddit%.com', icon = '󰑍 ' },
        stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
        wikipedia = { pattern = 'wikipedia%.org', icon = '󰖬 ' },
        youtube = { pattern = 'youtube%.com', icon = '󰗃 ' },
    },
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local pattern = {
        record = {
            pattern = { type = 'string' },
            icon = { type = 'string' },
            kind = { optional = true, enum = Kind },
            priority = { optional = true, type = 'number' },
            highlight = { optional = true, type = 'string' },
        },
    }
    return require('render-markdown.config.base').schema({
        footnote = {
            record = {
                enabled = { type = 'boolean' },
                superscript = { type = 'boolean' },
                prefix = { type = 'string' },
                suffix = { type = 'string' },
            },
        },
        image = { type = 'string' },
        email = { type = 'string' },
        hyperlink = { type = 'string' },
        highlight = { type = 'string' },
        wiki = {
            record = {
                icon = { type = 'string' },
                body = { type = 'function' },
                highlight = { type = 'string' },
                scope_highlight = { optional = true, type = 'string' },
            },
        },
        custom = { map = { key = { type = 'string' }, value = pattern } },
    })
end

return M
