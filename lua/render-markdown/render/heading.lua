local colors = require('render-markdown.colors')
local list = require('render-markdown.core.list')
local str = require('render-markdown.core.str')
local util = require('render-markdown.render.util')

---@class render.md.render.Heading: render.md.Renderer
---@field private config render.md.Heading
local Render = {}
Render.__index = Render

---@param buf integer
---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@return render.md.render.Heading
function Render.new(buf, marks, config, context)
    local self = setmetatable({}, Render)
    self.buf = buf
    self.marks = marks
    self.config = config.heading
    self.context = context
    return self
end

---@param info render.md.NodeInfo
function Render:render(info)
    if not self.config.enabled then
        return
    end

    local level = str.width(info.text)
    local foreground = list.clamp(self.config.foregrounds, level)
    local background = list.clamp(self.config.backgrounds, level)
    local heading_width = self.config.width
    if type(heading_width) == 'table' then
        heading_width = list.clamp(heading_width, level)
    end

    local icon_width = self:icon(info, level, foreground, background)
    if self.config.sign then
        util.sign(self.buf, self.marks, info, list.cycle(self.config.signs, level), foreground)
    end

    self.marks:add(true, info.start_row, 0, {
        end_row = info.end_row + 1,
        end_col = 0,
        hl_group = background,
        hl_eol = true,
    })

    local width = self:width(info, heading_width, icon_width)
    if heading_width == 'block' then
        -- Overwrite anything beyond width with Normal
        self.marks:add(true, info.start_row, 0, {
            priority = 0,
            virt_text = { { str.spaces(vim.o.columns * 2), 'Normal' } },
            virt_text_win_col = width,
        })
    end

    if self.config.border then
        self:border(info, level, foreground, colors.inverse(background), width)
    end

    if self.config.left_pad > 0 then
        self.marks:add(false, info.start_row, 0, {
            priority = 0,
            virt_text = { { str.spaces(self.config.left_pad), background } },
            virt_text_pos = 'inline',
        })
    end
end

---@private
---@param info render.md.NodeInfo
---@param level integer
---@param foreground string
---@param background string
---@return integer
function Render:icon(info, level, foreground, background)
    local icon = list.cycle(self.config.icons, level)

    -- Available width is level + 1 - concealed, where level = number of `#` characters, one
    -- is added to account for the space after the last `#` but before the heading title,
    -- and concealed text is subtracted since that space is not usable
    local width = level + 1 - self.context:concealed(info)
    if icon == nil then
        return width
    end

    local padding = width - str.width(icon)
    if self.config.position == 'inline' or padding < 0 then
        self.marks:add(true, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { icon, { foreground, background } } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        return str.width(icon)
    else
        self.marks:add(true, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { str.pad(padding, icon), { foreground, background } } },
            virt_text_pos = 'overlay',
        })
        return width
    end
end

---@private
---@param info render.md.NodeInfo
---@param heading_width render.md.heading.Width
---@param icon_width integer
---@return integer
function Render:width(info, heading_width, icon_width)
    if heading_width == 'block' then
        local width = self.config.left_pad + icon_width + self.config.right_pad
        local content = info:sibling('inline')
        if content ~= nil then
            width = width + str.width(content.text) + self.context:get_offset(content) - self.context:concealed(content)
        end
        return math.max(width, self.config.min_width)
    else
        return self.context:get_width()
    end
end

---@private
---@param info render.md.NodeInfo
---@param level integer
---@param foreground string
---@param background string
---@param width integer
function Render:border(info, level, foreground, background, width)
    local prefix = self.config.border_prefix and level or 0

    local line_above = {
        { self.config.above:rep(self.config.left_pad), background },
        { self.config.above:rep(prefix), foreground },
        { self.config.above:rep(width - self.config.left_pad - prefix), background },
    }
    if str.width(info:line('above')) == 0 and info.start_row - 1 ~= self.context.last_heading then
        self.marks:add(true, info.start_row - 1, 0, {
            virt_text = line_above,
            virt_text_pos = 'overlay',
        })
    else
        self.marks:add(false, info.start_row, 0, {
            virt_lines = { util.indent_virt_line(self.buf, info, line_above) },
            virt_lines_above = true,
        })
    end

    local line_below = {
        { self.config.below:rep(self.config.left_pad), background },
        { self.config.below:rep(prefix), foreground },
        { self.config.below:rep(width - self.config.left_pad - prefix), background },
    }
    if str.width(info:line('below')) == 0 then
        self.marks:add(true, info.end_row + 1, 0, {
            virt_text = line_below,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = info.end_row + 1
    else
        self.marks:add(false, info.end_row, 0, {
            virt_lines = { util.indent_virt_line(self.buf, info, line_below) },
        })
    end
end

return Render
