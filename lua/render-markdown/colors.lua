---@class render.md.ColorCache
---@field highlights string[]

---@type render.md.ColorCache
local cache = {
    highlights = {},
}

---@class render.md.Colors
local M = {}

---@param foreground string
---@param background string
---@return string
M.combine = function(foreground, background)
    local name = string.format('RenderMd_%s_%s', foreground, background)
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
    local name = string.format('RenderMd_Inverse_%s', highlight)
    if not vim.tbl_contains(cache.highlights, name) then
        local hl = M.get_hl(highlight)
        vim.api.nvim_set_hl(0, name, { fg = hl.bg, bg = hl.fg })
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
