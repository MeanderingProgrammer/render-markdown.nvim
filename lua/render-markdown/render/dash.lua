local Base = require('render-markdown.render.base')

---@class render.md.render.Dash: render.md.Renderer
---@field private dash render.md.Dash
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.dash = self.config.dash
    if not self.dash.enabled then
        return false
    end
    return true
end

function Render:render()
    local width = self.dash.width
    local win_width = vim.api.nvim_win_get_width(0)
    if type(width) == 'string' then
        if width == 'full' then
            width = win_width
        else
            width = width:gsub('%%', '')
            width = tonumber(width) / 100 * win_width
        end
    end
    local indent = ''
    if self.dash.align == 'center' then
        indent = string.rep(' ', (win_width - width) / 2)
    elseif self.dash.align == 'right' then
        indent = string.rep(' ', win_width - width)
    end
    local text = indent .. self.dash.icon:rep(width)

    local virt_text = { text, self.dash.highlight }

    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    self.marks:add('dash', start_row, 0, {
        virt_text = { virt_text },
        virt_text_pos = 'overlay',
    })
    if end_row > start_row then
        self.marks:add('dash', end_row, 0, {
            virt_text = { virt_text },
            virt_text_pos = 'overlay',
        })
    end
end

return Render
