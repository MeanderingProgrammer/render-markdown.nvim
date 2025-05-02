---@class render.md.icon.Provider
---@field name? string
---@field get fun(filetype: string): string?, string?

---@class render.md.icon.Providers
local Providers = {}

---@return render.md.icon.Provider?
function Providers.MiniIcons()
    local has, icons = pcall(require, 'mini.icons')
    if not has or not icons then
        return nil
    end
    local getter = icons.get
    if not getter then
        return nil
    end
    -- selene: allow(global_usage)
    -- additional check recommended by author
    if not _G.MiniIcons then
        return nil
    end
    ---@type render.md.icon.Provider
    return {
        name = 'mini.icons',
        get = function(filetype)
            return getter('filetype', filetype)
        end,
    }
end

---@return render.md.icon.Provider?
function Providers.DevIcons()
    local has, icons = pcall(require, 'nvim-web-devicons')
    if not has or not icons then
        return nil
    end
    local getter = icons.get_icon_by_filetype
    if not getter then
        return nil
    end
    ---@type render.md.icon.Provider
    return {
        name = 'nvim-web-devicons',
        get = function(filetype)
            return getter(filetype)
        end,
    }
end

---@return render.md.icon.Provider
function Providers.None()
    ---@type render.md.icon.Provider
    return {
        name = nil,
        get = function()
            return nil, nil
        end,
    }
end

---@class render.md.Icons
---@field private provider? render.md.icon.Provider
local M = {}

---@return string?
function M.name()
    return M.resolve().name
end

---@param name string
---@return string?, string?
function M.get(name)
    -- handle input possibly being an extension rather than a language name
    local filetype = vim.filetype.match({ filename = 'a.' .. name }) or name
    return M.resolve().get(filetype)
end

---@private
---@return render.md.icon.Provider
function M.resolve()
    local provider = M.provider
    if not provider then
        provider = provider or Providers.MiniIcons()
        provider = provider or Providers.DevIcons()
        provider = provider or Providers.None()
        M.provider = provider
    end
    return provider
end

return M
