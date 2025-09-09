---@class (exact) render.md.anti.conceal.Config
---@field enabled boolean
---@field disabled_modes render.md.Modes
---@field above integer
---@field below integer
---@field ignore render.md.conceal.Ignore

---@alias render.md.conceal.Ignore table<render.md.Element, render.md.Modes>

---@enum render.md.Element
local Element = {
    bullet = 'bullet',
    callout = 'callout',
    check_icon = 'check_icon',
    check_scope = 'check_scope',
    code_background = 'code_background',
    code_border = 'code_border',
    code_language = 'code_language',
    dash = 'dash',
    head_background = 'head_background',
    head_border = 'head_border',
    head_icon = 'head_icon',
    indent = 'indent',
    link = 'link',
    quote = 'quote',
    sign = 'sign',
    table_border = 'table_border',
    virtual_lines = 'virtual_lines',
}

---@class render.md.anti.conceal.Cfg
local M = {}

---@type render.md.anti.conceal.Config
M.default = {
    -- This enables hiding added text on the line the cursor is on.
    enabled = true,
    -- Modes to disable anti conceal feature.
    disabled_modes = false,
    -- Number of lines above cursor to show.
    above = 0,
    -- Number of lines below cursor to show.
    below = 0,
    -- Which elements to always show, ignoring anti conceal behavior. Values can either be
    -- booleans to fix the behavior or string lists representing modes where anti conceal
    -- behavior will be ignored. Valid values are:
    --   bullet
    --   callout
    --   check_icon, check_scope
    --   code_background, code_border, code_language
    --   dash
    --   head_background, head_border, head_icon
    --   indent
    --   link
    --   quote
    --   sign
    --   table_border
    --   virtual_lines
    ignore = {
        code_background = true,
        indent = true,
        sign = true,
        virtual_lines = true,
    },
}

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local modes = {
        union = { { list = { type = 'string' } }, { type = 'boolean' } },
    }
    ---@type render.md.Schema
    return {
        record = {
            enabled = { type = 'boolean' },
            disabled_modes = modes,
            above = { type = 'number' },
            below = { type = 'number' },
            ignore = { map = { { enum = Element }, modes } },
        },
    }
end

return M
