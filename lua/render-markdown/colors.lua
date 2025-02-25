---@class render.md.cache.Colors
---@field combine table<string, { fg: string, bg: string }>
---@field bg_to_fg table<string, { hl: string }>
local Cache = {
    combine = {},
    bg_to_fg = {},
}

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
    -- General
    Code            = 'ColorColumn',
    CodeInline      = 'RenderMarkdownCode',
    InlineHighlight = 'RenderMarkdownCodeInline',
    Bullet          = 'Normal',
    Quote           = '@markup.quote',
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

---Should only be called from plugin directory
function M.setup()
    -- Reload generated colors on color scheme change
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('RenderMarkdownColors', { clear = true }),
        callback = M.reload,
    })
    for name, link in pairs(M.colors) do
        vim.api.nvim_set_hl(0, M.prefix .. name, { link = link, default = true })
    end
end

---@private
function M.reload()
    for _, color in pairs(Cache.combine) do
        M.combine(color.fg, color.bg, true)
    end
    for _, color in pairs(Cache.bg_to_fg) do
        M.bg_to_fg(color.hl, true)
    end
end

---@param foreground string
---@param background string
---@param force? boolean
---@return string
function M.combine(foreground, background, force)
    local name = string.format('%s_%s_%s', M.prefix, foreground, background)
    if Cache.combine[name] == nil or force then
        local fg, bg = M.get_hl(foreground), M.get_hl(background)
        vim.api.nvim_set_hl(0, name, {
            fg = fg.fg,
            bg = bg.bg,
            ---@diagnostic disable-next-line: undefined-field
            ctermfg = fg.ctermfg,
            ---@diagnostic disable-next-line: undefined-field
            ctermbg = bg.ctermbg,
        })
        Cache.combine[name] = { fg = foreground, bg = background }
    end
    return name
end

---@param highlight string
---@param force? boolean
---@return string
function M.bg_to_fg(highlight, force)
    local name = string.format('%s_bgtofg_%s', M.prefix, highlight)
    if Cache.bg_to_fg[name] == nil or force then
        local hl = M.get_hl(highlight)
        vim.api.nvim_set_hl(0, name, {
            fg = hl.bg,
            ---@diagnostic disable-next-line: undefined-field
            ctermfg = hl.ctermbg,
        })
        Cache.bg_to_fg[name] = { hl = highlight }
    end
    return name
end

---@private
---@param name string
---@return vim.api.keyset.hl_info
function M.get_hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

return M
