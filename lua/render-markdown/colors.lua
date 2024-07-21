---@class render.md.ColorCache
---@field highlights string[]

---@type render.md.ColorCache
local cache = {
    highlights = {},
}

---@class render.md.Colors
local M = {}

---@private
---@type string
M.prefix = 'RenderMarkdown'

-- stylua: ignore
---@private
---@type table<string, string>
M.colors = {
    -- Headings
    H1        = '@markup.heading.1.markdown',
    H2        = '@markup.heading.2.markdown',
    H3        = '@markup.heading.3.markdown',
    H4        = '@markup.heading.4.markdown',
    H5        = '@markup.heading.5.markdown',
    H6        = '@markup.heading.6.markdown',
    H1Bg      = 'DiffAdd',
    H2Bg      = 'DiffChange',
    H3Bg      = 'DiffDelete',
    H4Bg      = 'DiffDelete',
    H5Bg      = 'DiffDelete',
    H6Bg      = 'DiffDelete',
    -- General
    Code      = 'ColorColumn',
    Bullet    = 'Normal',
    Quote     = '@markup.quote',
    Dash      = 'LineNr',
    Link      = '@markup.link.label.markdown_inline',
    Sign      = 'SignColumn',
    Math      = '@markup.math',
    -- Checkboxes
    Unchecked = '@markup.list.unchecked',
    Checked   = '@markup.list.checked',
    Todo      = '@markup.raw',
    -- Pipe tables
    TableHead = '@markup.heading',
    TableRow  = 'Normal',
    TableFill = 'Conceal',
    -- Callouts
    Success   = 'DiagnosticOk',
    Info      = 'DiagnosticInfo',
    Hint      = 'DiagnosticHint',
    Warn      = 'DiagnosticWarn',
    Error     = 'DiagnosticError',
}

function M.setup()
    for name, link in pairs(M.colors) do
        vim.api.nvim_set_hl(0, M.prefix .. name, { link = link, default = true })
    end
end

---@param foreground string
---@param background string
---@return string
M.combine = function(foreground, background)
    local name = string.format('%s_%s_%s', M.prefix, foreground, background)
    if not vim.tbl_contains(cache.highlights, name) then
        local fg = M.get_hl(foreground).fg
        local bg = M.get_hl(background).bg
        vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
        table.insert(cache.highlights, name)
    end
    return name
end

---@param highlight string
---@return string
M.inverse = function(highlight)
    local name = string.format('%s_Inverse_%s', M.prefix, highlight)
    if not vim.tbl_contains(cache.highlights, name) then
        local hl = M.get_hl(highlight)
        vim.api.nvim_set_hl(0, name, {
            fg = hl.bg,
            bg = hl.fg,
            ctermbg = hl.ctermfg,
            ctermfg = hl.ctermbg,
        })
        table.insert(cache.highlights, name)
    end
    return name
end

---@private
---@param name string
---@return vim.api.keyset.hl_info
M.get_hl = function(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

return M
