local Base = require('render-markdown.render.base')
local colors = require('render-markdown.colors')
local list = require('render-markdown.core.list')
local str = require('render-markdown.core.str')

---@class render.md.data.Heading
---@field atx boolean
---@field level integer
---@field icon? string
---@field sign? string
---@field foreground string
---@field background string
---@field heading_width render.md.heading.Width
---@field end_row integer

---@class render.md.render.Heading: render.md.Renderer
---@field private heading render.md.Heading
---@field private data render.md.data.Heading
local Render = setmetatable({}, Base)
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render:new(marks, config, context, info)
    return Base.new(self, marks, config, context, info)
end

---@return boolean
function Render:setup()
    self.heading = self.config.heading
    if not self.heading.enabled then
        return false
    end

    local atx, level = nil, nil
    if self.info.type == 'setext_heading' then
        atx, level = false, self.info:child('setext_h1_underline') ~= nil and 1 or 2
    else
        atx, level = true, str.width(self.info.text)
    end

    local heading_width = self.heading.width
    if type(heading_width) == 'table' then
        heading_width = list.clamp(heading_width, level)
    end

    self.data = {
        atx = atx,
        level = level,
        icon = list.cycle(self.heading.icons, level),
        sign = list.cycle(self.heading.signs, level),
        foreground = list.clamp(self.heading.foregrounds, level),
        background = list.clamp(self.heading.backgrounds, level),
        heading_width = heading_width,
        end_row = self.info.end_row + (atx and 1 or 0),
    }

    return true
end

function Render:render()
    local width = self:width(self:icon())
    if self.heading.sign then
        self:sign(self.data.sign, self.data.foreground)
    end
    self:background(width)
    self:border(width)
    self:left_pad()
    self:conceal_underline()
end

---@private
---@return integer
function Render:icon()
    if not self.data.atx then
        if self.data.icon == nil then
            return 0
        end
        local added = self.marks:add(true, self.info.start_row, self.info.start_col, {
            end_row = self.info.end_row,
            end_col = self.info.end_col,
            virt_text = { { self.data.icon, { self.data.foreground, self.data.background } } },
            virt_text_pos = 'inline',
        })
        return added and str.width(self.data.icon) or 0
    end

    -- For atx headings available width is level + 1 - concealed, where level = number of
    -- `#` characters, one is added to account for the space after the last `#` but before
    -- the  heading title, and concealed text is subtracted since that space is not usable
    local width = self.data.level + 1 - self.context:concealed(self.info)
    if self.data.icon == nil then
        return width
    end

    local padding = width - str.width(self.data.icon)
    if self.heading.position == 'inline' or padding < 0 then
        local added = self.marks:add(true, self.info.start_row, self.info.start_col, {
            end_row = self.info.end_row,
            end_col = self.info.end_col,
            virt_text = { { self.data.icon, { self.data.foreground, self.data.background } } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        return added and str.width(self.data.icon) or width
    else
        self.marks:add(true, self.info.start_row, self.info.start_col, {
            end_row = self.info.end_row,
            end_col = self.info.end_col,
            virt_text = { { str.pad(padding) .. self.data.icon, { self.data.foreground, self.data.background } } },
            virt_text_pos = 'overlay',
        })
        return width
    end
end

---@private
---@param icon_width integer
---@return integer
function Render:width(icon_width)
    if self.data.heading_width == 'block' then
        local width = nil
        if self.data.atx then
            width = icon_width + self.context:width(self.info:sibling('inline'))
        else
            -- Account for icon in first row
            local widths = vim.tbl_map(str.width, self.info:lines())
            widths[1] = widths[1] + icon_width
            width = vim.fn.max(widths)
        end
        width = self.heading.left_pad + width + self.heading.right_pad
        return math.max(width, self.heading.min_width)
    else
        return self.context:get_width()
    end
end

---@private
---@param width integer
function Render:background(width)
    local win_col = width + self:indent(self.data.level)
    for row = self.info.start_row, self.data.end_row - 1 do
        self.marks:add(true, row, 0, {
            end_row = row + 1,
            hl_group = self.data.background,
            hl_eol = true,
        })
        if self.data.heading_width == 'block' then
            -- Overwrite anything beyond width with Normal
            self.marks:add(true, row, 0, {
                priority = 0,
                virt_text = { { str.pad(vim.o.columns * 2), 'Normal' } },
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param width integer
function Render:border(width)
    -- Only atx headings support borders
    if not self.heading.border or not self.data.atx then
        return
    end

    local background = colors.inverse_bg(self.data.background)
    local prefix = self.heading.border_prefix and self.data.level or 0

    local line_above = {
        { self.heading.above:rep(self.heading.left_pad), background },
        { self.heading.above:rep(prefix), self.data.foreground },
        { self.heading.above:rep(width - self.heading.left_pad - prefix), background },
    }
    if str.width(self.info:line('above', 1)) == 0 and self.info.start_row - 1 ~= self.context.last_heading then
        self.marks:add(true, self.info.start_row - 1, 0, {
            virt_text = line_above,
            virt_text_pos = 'overlay',
        })
    else
        self.marks:add(false, self.info.start_row, 0, {
            virt_lines = { self:indent_virt_line(line_above, self.data.level) },
            virt_lines_above = true,
        })
    end

    local line_below = {
        { self.heading.below:rep(self.heading.left_pad), background },
        { self.heading.below:rep(prefix), self.data.foreground },
        { self.heading.below:rep(width - self.heading.left_pad - prefix), background },
    }
    if str.width(self.info:line('below', 1)) == 0 then
        self.marks:add(true, self.info.end_row + 1, 0, {
            virt_text = line_below,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = self.info.end_row + 1
    else
        self.marks:add(false, self.info.end_row, 0, {
            virt_lines = { self:indent_virt_line(line_below, self.data.level) },
        })
    end
end

---@private
function Render:left_pad()
    if self.heading.left_pad <= 0 then
        return
    end
    for row = self.info.start_row, self.data.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = { { str.pad(self.heading.left_pad), self.data.background } },
            virt_text_pos = 'inline',
        })
    end
end

---@private
function Render:conceal_underline()
    if self.data.atx then
        return
    end
    local info = self.info:child(string.format('setext_h%d_underline', self.data.level))
    if info == nil then
        return
    end
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        conceal = '',
    })
end

return Render
