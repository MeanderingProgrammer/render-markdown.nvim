local colors = require('render-markdown.colors')
local list = require('render-markdown.core.list')
local str = require('render-markdown.core.str')
local util = require('render-markdown.render.util')

---@class render.md.render.Heading: render.md.Renderer
---@field private heading render.md.Heading
---@field private level integer
---@field private icon? string
---@field private sign? string
---@field private foreground string
---@field private background string
---@field private heading_width render.md.heading.Width
local Render = {}
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render.new(marks, config, context, info)
    return setmetatable({ marks = marks, config = config, context = context, info = info }, Render)
end

---@return boolean
function Render:setup()
    self.heading = self.config.heading
    if not self.heading.enabled then
        return false
    end

    self.level = str.width(self.info.text)
    self.icon = list.cycle(self.heading.icons, self.level)
    self.sign = list.cycle(self.heading.signs, self.level)
    self.foreground = list.clamp(self.heading.foregrounds, self.level)
    self.background = list.clamp(self.heading.backgrounds, self.level)

    local heading_width = self.heading.width
    if type(heading_width) == 'table' then
        heading_width = list.clamp(heading_width, self.level)
    end
    self.heading_width = heading_width

    return true
end

function Render:render()
    local icon_width = self:start_icon()
    if self.heading.sign then
        util.sign(self.config, self.marks, self.info, self.sign, self.foreground)
    end

    self.marks:add(true, self.info.start_row, 0, {
        end_row = self.info.end_row + 1,
        end_col = 0,
        hl_group = self.background,
        hl_eol = true,
    })

    local width = self:width(icon_width)
    if self.heading_width == 'block' then
        -- Overwrite anything beyond width with Normal
        self.marks:add(true, self.info.start_row, 0, {
            priority = 0,
            virt_text = { { str.spaces(vim.o.columns * 2), 'Normal' } },
            virt_text_win_col = width,
        })
    end

    if self.heading.border then
        self:border(width)
    end

    if self.heading.left_pad > 0 then
        self.marks:add(false, self.info.start_row, 0, {
            priority = 0,
            virt_text = { { str.spaces(self.heading.left_pad), self.background } },
            virt_text_pos = 'inline',
        })
    end
end

---@private
---@return integer
function Render:start_icon()
    -- Available width is level + 1 - concealed, where level = number of `#` characters, one
    -- is added to account for the space after the last `#` but before the heading title,
    -- and concealed text is subtracted since that space is not usable
    local width = self.level + 1 - self.context:concealed(self.info)
    if self.icon == nil then
        return width
    end

    local padding = width - str.width(self.icon)
    if self.heading.position == 'inline' or padding < 0 then
        self.marks:add(true, self.info.start_row, self.info.start_col, {
            end_row = self.info.end_row,
            end_col = self.info.end_col,
            virt_text = { { self.icon, { self.foreground, self.background } } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        return str.width(self.icon)
    else
        self.marks:add(true, self.info.start_row, self.info.start_col, {
            end_row = self.info.end_row,
            end_col = self.info.end_col,
            virt_text = { { str.pad(padding, self.icon), { self.foreground, self.background } } },
            virt_text_pos = 'overlay',
        })
        return width
    end
end

---@private
---@param icon_width integer
---@return integer
function Render:width(icon_width)
    if self.heading_width == 'block' then
        local width = self.heading.left_pad + icon_width + self.heading.right_pad
        local content = self.info:sibling('inline')
        if content ~= nil then
            width = width + str.width(content.text) + self.context:get_offset(content) - self.context:concealed(content)
        end
        return math.max(width, self.heading.min_width)
    else
        return self.context:get_width()
    end
end

---@private
---@param width integer
function Render:border(width)
    local background = colors.inverse(self.background)
    local prefix = self.heading.border_prefix and self.level or 0

    local line_above = {
        { self.heading.above:rep(self.heading.left_pad), background },
        { self.heading.above:rep(prefix), self.foreground },
        { self.heading.above:rep(width - self.heading.left_pad - prefix), background },
    }
    if str.width(self.info:line('above')) == 0 and self.info.start_row - 1 ~= self.context.last_heading then
        self.marks:add(true, self.info.start_row - 1, 0, {
            virt_text = line_above,
            virt_text_pos = 'overlay',
        })
    else
        self.marks:add(false, self.info.start_row, 0, {
            virt_lines = { util.indent_virt_line(self.config, self.info, line_above) },
            virt_lines_above = true,
        })
    end

    local line_below = {
        { self.heading.below:rep(self.heading.left_pad), background },
        { self.heading.below:rep(prefix), self.foreground },
        { self.heading.below:rep(width - self.heading.left_pad - prefix), background },
    }
    if str.width(self.info:line('below')) == 0 then
        self.marks:add(true, self.info.end_row + 1, 0, {
            virt_text = line_below,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = self.info.end_row + 1
    else
        self.marks:add(false, self.info.end_row, 0, {
            virt_lines = { util.indent_virt_line(self.config, self.info, line_below) },
        })
    end
end

return Render
