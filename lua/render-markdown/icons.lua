local has_mini_icons, mini_icons = pcall(require, 'mini.icons')
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

---@class render.md.IconProvider
local M = {}

---@param language string
---@return string?
---@return string?
M.get = function(language)
    if has_mini_icons then
        ---@diagnostic disable-next-line: return-type-mismatch
        return mini_icons.get('filetype', language)
    elseif has_devicons then
        return devicons.get_icon_by_filetype(language)
    else
        return nil, nil
    end
end

return M
