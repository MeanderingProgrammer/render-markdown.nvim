local has_mini_icons, mini_icons = pcall(require, 'mini.icons')
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

---@class render.md.IconProvider
local M = {}

---@param name string
---@return string?, string?
function M.get(name)
    -- Handle input possibly being an extension rather than a language name
    local file_type = vim.filetype.match({ filename = 'a.' .. name }) or name

    if has_mini_icons then
        ---@diagnostic disable-next-line: return-type-mismatch
        return mini_icons.get('filetype', file_type)
    elseif has_devicons then
        return devicons.get_icon_by_filetype(file_type)
    else
        return nil, nil
    end
end

---@return string?
function M.provider()
    if has_mini_icons then
        return 'mini.icons'
    elseif has_devicons then
        return 'nvim-web-devicons'
    else
        return nil
    end
end

return M
