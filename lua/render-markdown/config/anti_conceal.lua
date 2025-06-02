---@class (exact) render.md.anti.conceal.Config
---@field enabled boolean
---@field disabled_modes render.md.Modes
---@field above integer
---@field below integer
---@field ignore render.md.conceal.Ignore

---@alias render.md.conceal.Ignore table<render.md.Element, render.md.Modes>

---@enum render.md.Element
local Element = {
    head_icon = 'head_icon',
    head_background = 'head_background',
    head_border = 'head_border',
    code_language = 'code_language',
    code_background = 'code_background',
    code_border = 'code_border',
    dash = 'dash',
    bullet = 'bullet',
    check_icon = 'check_icon',
    check_scope = 'check_scope',
    quote = 'quote',
    table_border = 'table_border',
    callout = 'callout',
    link = 'link',
    sign = 'sign',
}

---@class render.md.anti.conceal.Cfg
local M = {}

---@type render.md.anti.conceal.Config
M.default = {
    -- This enables hiding any added text on the line the cursor is on.
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
    --   head_icon, head_background, head_border, code_language, code_background, code_border,
    --   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
    ignore = {
        code_background = true,
        sign = true,
    },
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('enabled', 'boolean')
    spec:list('disabled_modes', 'string', 'boolean')
    spec:type('above', 'number')
    spec:type('below', 'number')
    spec:nested('ignore', function(ignore)
        for _, element in pairs(Element) do
            ignore:list(element, 'string', { 'boolean', 'nil' })
        end
        ignore:check()
    end)
    spec:check()
end

return M
