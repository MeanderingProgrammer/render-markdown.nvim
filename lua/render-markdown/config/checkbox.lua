---@class (exact) render.md.checkbox.Config: render.md.base.Config
---@field bullet boolean
---@field right_pad integer
---@field unchecked render.md.checkbox.component.Config
---@field checked render.md.checkbox.component.Config
---@field custom table<string, render.md.checkbox.custom.Config>

---@class (exact) render.md.checkbox.component.Config
---@field icon string
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.checkbox.custom.Config
---@field raw string
---@field rendered string
---@field highlight string
---@field scope_highlight? string

---@class render.md.checkbox.Cfg
local M = {}

---@type render.md.checkbox.Config
M.default = {
    -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'.
    -- There are two special states for unchecked & checked defined in the markdown grammar.

    -- Turn on / off checkbox state rendering.
    enabled = true,
    -- Additional modes to render checkboxes.
    render_modes = false,
    -- Render the bullet point before the checkbox.
    bullet = false,
    -- Padding to add to the right of checkboxes.
    right_pad = 1,
    unchecked = {
        -- Replaces '[ ]' of 'task_list_marker_unchecked'.
        icon = '󰄱 ',
        -- Highlight for the unchecked icon.
        highlight = 'RenderMarkdownUnchecked',
        -- Highlight for item associated with unchecked checkbox.
        scope_highlight = nil,
    },
    checked = {
        -- Replaces '[x]' of 'task_list_marker_checked'.
        icon = '󰱒 ',
        -- Highlight for the checked icon.
        highlight = 'RenderMarkdownChecked',
        -- Highlight for item associated with checked checkbox.
        scope_highlight = nil,
    },
    -- Define custom checkbox states, more involved, not part of the markdown grammar.
    -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | raw             | matched against the raw text of a 'shortcut_link'           |
    -- | rendered        | replaces the 'raw' value when rendering                     |
    -- | highlight       | highlight for the 'rendered' icon                           |
    -- | scope_highlight | optional highlight for item associated with custom checkbox |
    -- stylua: ignore
    custom = {
        todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
    },
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local component = {
        record = {
            icon = { type = 'string' },
            highlight = { type = 'string' },
            scope_highlight = { optional = true, type = 'string' },
        },
    }
    ---@type render.md.Schema
    local custom = {
        record = {
            raw = { type = 'string' },
            rendered = { type = 'string' },
            highlight = { type = 'string' },
            scope_highlight = { optional = true, type = 'string' },
        },
    }
    return require('render-markdown.config.base').schema({
        bullet = { type = 'boolean' },
        right_pad = { type = 'number' },
        unchecked = component,
        checked = component,
        custom = { map = { key = { type = 'string' }, value = custom } },
    })
end

return M
