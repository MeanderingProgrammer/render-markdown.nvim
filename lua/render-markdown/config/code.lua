---@class (exact) render.md.code.Config: render.md.base.Config
---@field sign boolean
---@field style render.md.code.Style
---@field position render.md.code.Position
---@field language_pad number
---@field language_icon boolean
---@field language_name boolean
---@field disable_background boolean|string[]
---@field width render.md.code.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field border render.md.code.Border
---@field above string
---@field below string
---@field inline_left string
---@field inline_right string
---@field inline_pad integer
---@field highlight string
---@field highlight_language? string
---@field highlight_border string|boolean
---@field highlight_fallback string
---@field highlight_inline string

---@enum render.md.code.Style
local Style = {
    full = 'full',
    normal = 'normal',
    language = 'language',
    none = 'none',
}

---@enum render.md.code.Position
local Position = {
    left = 'left',
    right = 'right',
}

---@enum render.md.code.Width
local Width = {
    full = 'full',
    block = 'block',
}

---@enum render.md.code.Border
local Border = {
    hide = 'hide',
    thin = 'thin',
    thick = 'thick',
    none = 'none',
}

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('sign', 'boolean')
    spec:one_of('style', vim.tbl_values(Style))
    spec:one_of('position', vim.tbl_values(Position))
    spec:type('language_pad', 'number')
    spec:type('language_icon', 'boolean')
    spec:type('language_name', 'boolean')
    spec:list('disable_background', 'string', 'boolean')
    spec:one_of('width', vim.tbl_values(Width))
    spec:type('left_margin', 'number')
    spec:type('left_pad', 'number')
    spec:type('right_pad', 'number')
    spec:type('min_width', 'number')
    spec:one_of('border', vim.tbl_values(Border))
    spec:type('above', 'string')
    spec:type('below', 'string')
    spec:type('inline_left', 'string')
    spec:type('inline_right', 'string')
    spec:type('inline_pad', 'number')
    spec:type('highlight', 'string')
    spec:type('highlight_language', { 'string', 'nil' })
    spec:type('highlight_border', { 'string', 'boolean' })
    spec:type('highlight_fallback', 'string')
    spec:type('highlight_inline', 'string')
    spec:check()
end

return M
