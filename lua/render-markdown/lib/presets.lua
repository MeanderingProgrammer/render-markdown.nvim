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
    return vim.tbl_deep_extend('force', M.config_preset[user.preset] or {}, {
        code = M.code_style[(user.code or {}).style] or {},
        pipe_table = vim.tbl_deep_extend(
            'force',
            M.table_preset[(user.pipe_table or {}).preset] or {},
            M.table_style[(user.pipe_table or {}).style] or {}
        ),
        win_options = M.win_options[(user.anti_conceal or {}).enabled] or {},
    })
end

---@private
---@type table<render.md.config.Preset?, render.md.UserConfig?>
M.config_preset = {
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

---@private
---@type table<render.md.code.Style?, render.md.code.UserConfig?>
M.code_style = {
    ['none'] = { enabled = false },
    ['normal'] = { language = false },
    ['language'] = { disable_background = true, inline = false },
}

---@private
---@type table<render.md.table.Preset?, render.md.table.UserConfig?>
M.table_preset = {
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

---@private
---@type table<render.md.table.Style?, render.md.table.UserConfig?>
M.table_style = {
    ['none'] = { enabled = false },
    ['normal'] = { border_enabled = false },
}

---@private
---@type table<boolean?, render.md.window.UserConfigs?>
M.win_options = {
    [false] = { concealcursor = { rendered = 'nvic' } },
}

return M
