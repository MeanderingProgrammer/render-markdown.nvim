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

---@enum (key) render.md.code.Style
local Style = {
    full = 'full',
    normal = 'normal',
    language = 'language',
    none = 'none',
}

---@enum (key) render.md.code.Position
local Position = {
    left = 'left',
    right = 'right',
}

---@enum (key) render.md.code.Width
local Width = {
    full = 'full',
    block = 'block',
}

---@enum (key) render.md.code.Border
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
        :one_of('style', vim.tbl_keys(Style))
        :one_of('position', vim.tbl_keys(Position))
        :type('language_pad', 'number')
        :type('language_icon', 'boolean')
        :type('language_name', 'boolean')
        :list('disable_background', 'string', 'boolean')
        :one_of('width', vim.tbl_keys(Width))
        :type('left_margin', 'number')
        :type('left_pad', 'number')
        :type('right_pad', 'number')
        :type('min_width', 'number')
        :one_of('border', vim.tbl_keys(Border))
        :type('above', 'string')
        :type('below', 'string')
        :type('inline_left', 'string')
        :type('inline_right', 'string')
        :type('inline_pad', 'number')
        :type('highlight', 'string')
        :type('highlight_language', { 'string', 'nil' })
        :type('highlight_border', { 'string', 'boolean' })
        :type('highlight_fallback', 'string')
        :type('highlight_inline', 'string')
        :check()
end

return M
