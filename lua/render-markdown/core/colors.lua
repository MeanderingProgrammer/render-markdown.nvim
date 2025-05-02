---@class render.md.Colors
local M = {}

---@private
M.prefix = 'RenderMarkdown'

-- stylua: ignore
---@private
---@type table<string, string>
M.colors = {
    -- Headings
    H1              = '@markup.heading.1.markdown',
    H2              = '@markup.heading.2.markdown',
    H3              = '@markup.heading.3.markdown',
    H4              = '@markup.heading.4.markdown',
    H5              = '@markup.heading.5.markdown',
    H6              = '@markup.heading.6.markdown',
    H1Bg            = 'DiffAdd',
    H2Bg            = 'DiffChange',
    H3Bg            = 'DiffDelete',
    H4Bg            = 'DiffDelete',
    H5Bg            = 'DiffDelete',
    H6Bg            = 'DiffDelete',
    -- Code
    Code            = 'ColorColumn',
    CodeBorder      = 'RenderMarkdownCode',
    CodeFallback    = 'Normal',
    CodeInline      = 'RenderMarkdownCode',
    -- Block quotes
    Quote           = '@markup.quote',
    Quote1          = 'RenderMarkdownQuote',
    Quote2          = 'RenderMarkdownQuote',
    Quote3          = 'RenderMarkdownQuote',
    Quote4          = 'RenderMarkdownQuote',
    Quote5          = 'RenderMarkdownQuote',
    Quote6          = 'RenderMarkdownQuote',
    -- General
    InlineHighlight = 'RenderMarkdownCodeInline',
    Bullet          = 'Normal',
    Dash            = 'LineNr',
    Sign            = 'SignColumn',
    Math            = '@markup.math',
    Indent          = 'Whitespace',
    HtmlComment     = '@comment',
    -- Links
    Link            = '@markup.link.label.markdown_inline',
    WikiLink        = 'RenderMarkdownLink',
    -- Checkboxes
    Unchecked       = '@markup.list.unchecked',
    Checked         = '@markup.list.checked',
    Todo            = '@markup.raw',
    -- Pipe tables
    TableHead       = '@markup.heading',
    TableRow        = 'Normal',
    TableFill       = 'Conceal',
    -- Callouts
    Success         = 'DiagnosticOk',
    Info            = 'DiagnosticInfo',
    Hint            = 'DiagnosticHint',
    Warn            = 'DiagnosticWarn',
    Error           = 'DiagnosticError',
}

---@private
---@class render.md.colors.Cache
M.cache = {}
---@type table<string, { fg: string, bg: string }>
M.cache.combine = {}
---@type table<string, { hl: string }>
M.cache.bg_as_fg = {}

---called from plugin directory
function M.init()
    for name, link in pairs(M.colors) do
        vim.api.nvim_set_hl(0, M.prefix .. name, {
            link = link,
            default = true,
        })
    end
    -- reload generated colors on color scheme change
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('RenderMarkdownColors', {}),
        callback = M.reload,
    })
end

---@private
function M.reload()
    for _, color in pairs(M.cache.combine) do
        M.combine(color.fg, color.bg, true)
    end
    for _, color in pairs(M.cache.bg_as_fg) do
        M.bg_as_fg(color.hl, true)
    end
end

---@param foreground string
---@param background string
---@param force? boolean
---@return string
function M.combine(foreground, background, force)
    local name = ('%s_%s_%s'):format(M.prefix, foreground, background)
    if not M.cache.combine[name] or force then
        local fg, bg = M.get_hl(foreground), M.get_hl(background)
        vim.api.nvim_set_hl(0, name, {
            fg = fg.fg,
            bg = bg.bg,
            ctermfg = fg.ctermfg,
            ctermbg = bg.ctermbg,
        })
        M.cache.combine[name] = { fg = foreground, bg = background }
    end
    return name
end

---@param highlight string
---@param force? boolean
---@return string
function M.bg_as_fg(highlight, force)
    local name = ('%s_%s_bg_as_fg'):format(M.prefix, highlight)
    if not M.cache.bg_as_fg[name] or force then
        local hl = M.get_hl(highlight)
        vim.api.nvim_set_hl(0, name, {
            fg = hl.bg,
            ctermfg = hl.ctermbg,
        })
        M.cache.bg_as_fg[name] = { hl = highlight }
    end
    return name
end

---@private
---@param name string
---@return vim.api.keyset.get_hl_info
function M.get_hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

return M
