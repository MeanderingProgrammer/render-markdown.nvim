local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.lib.iter')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.data.Heading
---@field atx boolean
---@field level integer
---@field icon? string
---@field sign? string
---@field foreground? string
---@field background? string
---@field width render.md.heading.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field end_row integer

---@class render.md.width.Heading
---@field margin integer
---@field padding integer
---@field content integer

---@class render.md.render.Heading: render.md.Renderer
---@field private heading render.md.Heading
---@field private data render.md.data.Heading
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.heading = self.config.heading
    if not self.heading.enabled then
        return false
    end

    local atx, level = nil, nil
    if self.node.type == 'setext_heading' then
        atx, level = false, self.node:child('setext_h1_underline') ~= nil and 1 or 2
    else
        atx, level = true, Str.width(self.node.text)
    end

    self.data = {
        atx = atx,
        level = level,
        icon = List.cycle(self.heading.icons, level),
        sign = List.cycle(self.heading.signs, level),
        foreground = List.clamp(self.heading.foregrounds, level),
        background = List.clamp(self.heading.backgrounds, level),
        width = List.clamp(self.heading.width, level) or 'full',
        left_margin = List.clamp(self.heading.left_margin, level) or 0,
        left_pad = List.clamp(self.heading.left_pad, level) or 0,
        right_pad = List.clamp(self.heading.right_pad, level) or 0,
        min_width = List.clamp(self.heading.min_width, level) or 0,
        end_row = self.node.end_row + (atx and 1 or 0),
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
    self:left_pad(width)
    self:conceal_underline()
end

---@private
---@return integer
function Render:icon()
    local icon, highlight = self.data.icon, {}
    if self.data.foreground ~= nil then
        table.insert(highlight, self.data.foreground)
    end
    if self.data.background ~= nil then
        table.insert(highlight, self.data.background)
    end

    if not self.data.atx then
        if icon == nil or #highlight == 0 then
            return 0
        end
        local added = true
        for row = self.node.start_row, self.data.end_row - 1 do
            added = added
                and self.marks:add('head_icon', row, self.node.start_col, {
                    end_row = row,
                    end_col = self.node.end_col,
                    virt_text = { { row == self.node.start_row and icon or Str.pad(Str.width(icon)), highlight } },
                    virt_text_pos = 'inline',
                })
        end
        return added and Str.width(icon) or 0
    end

    -- For atx headings available width is level + 1 - concealed, where level = number of
    -- `#` characters, one is added to account for the space after the last `#` but before
    -- the  heading title, and concealed text is subtracted since that space is not usable
    local width = self.data.level + 1 - self.context:concealed(self.node)
    if icon == nil or #highlight == 0 then
        return width
    end

    local padding = width - Str.width(icon)
    if self.heading.position == 'inline' or padding < 0 then
        local added = self.marks:add('head_icon', self.node.start_row, self.node.start_col, {
            end_row = self.node.end_row,
            end_col = self.node.end_col,
            virt_text = { { icon, highlight } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        return added and Str.width(icon) + 1 or width
    else
        self.marks:add('head_icon', self.node.start_row, self.node.start_col, {
            end_row = self.node.end_row,
            end_col = self.node.end_col,
            virt_text = { { Str.pad(padding) .. icon, highlight } },
            virt_text_pos = 'overlay',
        })
        return width
    end
end

---@private
---@param icon_width integer
---@return render.md.width.Heading
function Render:width(icon_width)
    local text_width = nil
    if self.data.atx then
        text_width = self.context:width(self.node:sibling('inline'))
    else
        text_width = vim.fn.max(Iter.list.map(self.node:lines(), Str.width))
    end
    local width = icon_width + text_width
    local left_padding = self.context:resolve_offset(self.data.left_pad, width)
    local right_padding = self.context:resolve_offset(self.data.right_pad, width)
    width = math.max(left_padding + width + right_padding, self.data.min_width)
    ---@type render.md.width.Heading
    return {
        margin = self.context:resolve_offset(self.data.left_margin, width),
        padding = left_padding,
        content = self.data.width == 'block' and width or self.context:get_width(),
    }
end

---@private
---@param width render.md.width.Heading
function Render:background(width)
    local highlight = self.data.background
    if highlight == nil then
        return
    end
    local win_col, padding = 0, {}
    if self.data.width == 'block' then
        win_col = width.margin + width.content + self:indent(self.data.level)
        table.insert(padding, { Str.pad(vim.o.columns * 2), self.config.padding.highlight })
    end
    for row = self.node.start_row, self.data.end_row - 1 do
        self.marks:add('head_background', row, 0, {
            end_row = row + 1,
            hl_group = highlight,
            hl_eol = true,
        })
        if win_col > 0 and #padding > 0 then
            -- Overwrite anything beyond width with padding highlight
            self.marks:add('head_background', row, 0, {
                priority = 0,
                virt_text = padding,
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param width render.md.width.Heading
function Render:border(width)
    -- Only atx headings support borders
    if not self.heading.border or not self.data.atx then
        return
    end

    local foreground = self.data.foreground
    local background = self.data.background and colors.bg_to_fg(self.data.background)
    local prefix = self.heading.border_prefix and self.data.level or 0
    local virtual = self.heading.border_virtual

    ---@param icon string
    ---@return { [1]: string, [2]: string }[]
    local function line(icon)
        ---@param size integer
        ---@param highlight? string
        ---@return { [1]: string, [2]: string }
        local function section(size, highlight)
            if highlight ~= nil then
                return { icon:rep(size), highlight }
            else
                return { Str.pad(size), self.config.padding.highlight }
            end
        end
        return {
            section(width.margin, nil),
            section(width.padding, background),
            section(prefix, foreground),
            section(width.content - width.padding - prefix, background),
        }
    end

    local line_above = line(self.heading.above)
    if not virtual and self:empty_line('above') and self.node.start_row - 1 ~= self.context.last_heading then
        self.marks:add('head_border', self.node.start_row - 1, 0, {
            virt_text = line_above,
            virt_text_pos = 'overlay',
        })
    else
        self.marks:add(false, self.node.start_row, 0, {
            virt_lines = { self:indent_virt_line(line_above, self.data.level) },
            virt_lines_above = true,
        })
    end

    local line_below = line(self.heading.below)
    if not virtual and self:empty_line('below') then
        self.marks:add('head_border', self.node.end_row + 1, 0, {
            virt_text = line_below,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = self.node.end_row + 1
    else
        self.marks:add(false, self.node.end_row, 0, {
            virt_lines = { self:indent_virt_line(line_below, self.data.level) },
        })
    end
end

---@private
---@param position 'above'|'below'
---@return boolean
function Render:empty_line(position)
    local line = self.node:line(position, 1)
    return line ~= nil and Str.width(line) == 0
end

---@private
---@param width render.md.width.Heading
function Render:left_pad(width)
    local virt_text = {}
    ---@param size integer
    ---@param highlight? string
    local function append(size, highlight)
        if size > 0 then
            table.insert(virt_text, { Str.pad(size), highlight or self.config.padding.highlight })
        end
    end
    append(width.margin, nil)
    append(width.padding, self.data.background)
    if #virt_text > 0 then
        for row = self.node.start_row, self.data.end_row - 1 do
            self.marks:add(false, row, 0, {
                priority = 0,
                virt_text = virt_text,
                virt_text_pos = 'inline',
            })
        end
    end
end

---@private
function Render:conceal_underline()
    if self.data.atx then
        return
    end
    local node = self.node:child(string.format('setext_h%d_underline', self.data.level))
    if node == nil then
        return
    end
    self.marks:add(true, node.start_row, node.start_col, {
        end_row = node.end_row,
        end_col = node.end_col,
        conceal = '',
    })
end

return Render
