---@class render.md.Presets
local M = {}

---@param user_config render.md.UserConfig
---@return render.md.UserConfig
function M.get(user_config)
    local config = M.config_preset(user_config.preset)
    config.pipe_table = M.pipe_table_preset((user_config.pipe_table or {}).preset)
    return config
end

---@private
---@param name? render.md.config.Preset
---@return render.md.UserConfig
function M.config_preset(name)
    if name == 'obsidian' then
        ---@type render.md.UserConfig
        return {
            render_modes = true,
        }
    elseif name == 'lazy' then
        ---https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/markdown.lua
        ---@type render.md.UserConfig
        return {
            file_types = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
            code = {
                sign = false,
                width = 'block',
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
            checkbox = {
                enabled = false,
            },
        }
    else
        ---@type render.md.UserConfig
        return {}
    end
end

---@private
---@param name? render.md.table.Preset
---@return render.md.UserPipeTable
function M.pipe_table_preset(name)
    if name == 'round' then
        ---@type render.md.UserPipeTable
        return {
            -- stylua: ignore
            border = {
                '╭', '┬', '╮',
                '├', '┼', '┤',
                '╰', '┴', '╯',
                '│', '─',
            },
        }
    elseif name == 'double' then
        ---@type render.md.UserPipeTable
        return {
            -- stylua: ignore
            border = {
                '╔', '╦', '╗',
                '╠', '╬', '╣',
                '╚', '╩', '╝',
                '║', '═',
            },
        }
    elseif name == 'heavy' then
        ---@type render.md.UserPipeTable
        return {
            alignment_indicator = '─',
            -- stylua: ignore
            border = {
                '┏', '┳', '┓',
                '┣', '╋', '┫',
                '┗', '┻', '┛',
                '┃', '━',
            },
        }
    else
        ---@type render.md.UserPipeTable
        return {}
    end
end

return M
