---@enum render.md.config.Preset
local Preset = {
    obsidian = 'obsidian',
    lazy = 'lazy',
    none = 'none',
}

---@class render.md.Presets
local M = {}

---@param user render.md.UserConfig
---@return render.md.UserConfig
function M.get(user)
    return vim.tbl_deep_extend('force', M.config(user), {
        code = M.code(user),
        pipe_table = M.pipe_table(user),
        win_options = M.win_options(user),
    })
end

---@private
---@param user render.md.UserConfig
---@return render.md.UserConfig
function M.config(user)
    ---@type table<render.md.config.Preset?, render.md.UserConfig?>
    local presets = {
        [Preset.obsidian] = { render_modes = true },
        ---https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/markdown.lua
        [Preset.lazy] = {
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
        },
    }
    return presets[user.preset] or {}
end

---@private
---@param user render.md.UserConfig
---@return render.md.code.UserConfig
function M.code(user)
    ---@type table<render.md.code.Style?, render.md.code.UserConfig?>
    local styles = {
        ['none'] = { enabled = false },
        ['normal'] = { language = false },
        ['language'] = { disable_background = true, inline = false },
    }
    return styles[(user.code or {}).style] or {}
end

---@private
---@param user render.md.UserConfig
---@return render.md.table.UserConfig
function M.pipe_table(user)
    ---@type table<render.md.table.Preset?, render.md.table.UserConfig?>
    local presets = {
        ['round'] = {
            -- stylua: ignore
            border = {
                '╭', '┬', '╮',
                '├', '┼', '┤',
                '╰', '┴', '╯',
                '│', '─',
            },
        },
        ['double'] = {
            -- stylua: ignore
            border = {
                '╔', '╦', '╗',
                '╠', '╬', '╣',
                '╚', '╩', '╝',
                '║', '═',
            },
        },
        ['heavy'] = {
            alignment_indicator = '─',
            -- stylua: ignore
            border = {
                '┏', '┳', '┓',
                '┣', '╋', '┫',
                '┗', '┻', '┛',
                '┃', '━',
            },
        },
    }
    ---@type table<render.md.table.Style?, render.md.table.UserConfig?>
    local styles = {
        ['none'] = { enabled = false },
        ['normal'] = { border_enabled = false },
    }
    local preset = presets[(user.pipe_table or {}).preset] or {}
    local style = styles[(user.pipe_table or {}).style] or {}
    return vim.tbl_deep_extend('force', preset, style)
end

---@private
---@param user render.md.UserConfig
---@return render.md.window.UserConfigs
function M.win_options(user)
    ---@type table<boolean?, render.md.window.UserConfigs?>
    local anti_conceals = {
        [false] = { concealcursor = { rendered = 'nvic' } },
    }
    return anti_conceals[(user.anti_conceal or {}).enabled] or {}
end

return M
