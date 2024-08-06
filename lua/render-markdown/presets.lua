---@class render.md.Presets
local M = {}

---@param user_config render.md.UserConfig
---@return render.md.UserConfig
function M.get(user_config)
    local name = user_config.preset
    if name == 'obsidian' then
        ---@type render.md.UserConfig
        return {
            render_modes = { 'n', 'v', 'i', 'c' },
        }
    elseif name == 'lazy' then
        ---https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/markdown.lua
        ---@type render.md.UserConfig
        return {
            file_types = { 'markdown', 'norg', 'rmd', 'org' },
            code = {
                sign = false,
                width = 'block',
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
        }
    else
        return {}
    end
end

return M
