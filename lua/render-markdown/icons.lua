local ok, devicons = pcall(require, 'nvim-web-devicons')

local M = {}

---@param language string
---@return string?
---@return string?
M.get = function(language)
    if ok then
        return devicons.get_icon_by_filetype(language)
    else
        return nil, nil
    end
end

return M
