local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.lib.iter')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.data.Heading
---@field atx boolean
---@field marker render.md.Node
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
---@field border boolean

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
    if self.context:skip(self.heading) then
        return false
    end
    if self.context:hidden(self.node) then
        return false
    end

    local atx = nil
    local marker = nil
    local level = nil
    if self.node.type == 'atx_heading' then
        atx = true
        marker = assert(self.node:child_at(0), 'atx heading expected child marker')
        level = Str.width(marker.text)
    elseif self.node.type == 'setext_heading' then
        atx = false
        marker = assert(self.node:child_at(1), 'ext heading expected child underline')
        level = marker.type == 'setext_h1_underline' and 1 or 2
    else
        return false
    end

    local custom = self:custom()

    local icon, icons = nil, self.heading.icons
    if type(icons) == 'function' then
        icon = icons({ sections = self.node:sections() })
    else
        icon = List.cycle(icons, level)
    end

    self.data = {
        atx = atx,
        marker = marker,
        level = level,
        icon = custom.icon or icon,
        sign = List.cycle(self.heading.signs, level),
        foreground = custom.foreground or List.clamp(self.heading.foregrounds, level),
        background = custom.background or List.clamp(self.heading.backgrounds, level),
        width = List.clamp(self.heading.width, level) or 'full',
        left_margin = List.clamp(self.heading.left_margin, level) or 0,
        left_pad = List.clamp(self.heading.left_pad, level) or 0,
        right_pad = List.clamp(self.heading.right_pad, level) or 0,
        min_width = List.clamp(self.heading.min_width, level) or 0,
        border = List.clamp(self.heading.border, level) or false,
    }

    return true
end

---@private
---@return render.md.HeadingCustom
function Render:custom()
    for _, custom in pairs(self.heading.custom) do
        if self.node.text:find(custom.pattern) ~= nil then
            return custom
        end
    end
    return {}
end

function Render:render()
    if self.heading.sign then
        self:sign(self.data.sign, self.data.foreground)
    end
    local width = self:width(self:icon())
    self:background(width)
    self:left_pad(width)
    if self.data.atx then
        self:border(width, 'above', self.heading.above, self.node.start_row - 1)
        self:border(width, 'below', self.heading.below, self.node.end_row)
    else
        self:conceal_underline()
    end
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
    if self.data.atx then
        local marker = self.data.marker
        -- Add 1 to account for space after last `#`
        local width = self.context:width(marker) + 1
        if icon == nil or #highlight == 0 then
            return width
        end
        if self.heading.position == 'right' then
            self.marks:add_over(true, marker, { conceal = '' }, { 0, 0, 0, 1 })
            self.marks:add_over('head_icon', marker, {
                priority = 1000,
                virt_text = { { icon, highlight } },
                virt_text_pos = 'eol',
            })
            return 1 + Str.width(icon)
        else
            local padding = width - Str.width(icon)
            if self.heading.position == 'inline' or padding < 0 then
                local added = self.marks:add_over('head_icon', marker, {
                    virt_text = { { icon, highlight } },
                    virt_text_pos = 'inline',
                    conceal = '',
                }, { 0, 0, 0, 1 })
                return added and Str.width(icon) or width
            else
                self.marks:add_over('head_icon', marker, {
                    virt_text = { { Str.pad(padding) .. icon, highlight } },
                    virt_text_pos = 'overlay',
                })
                return width
            end
        end
    else
        local node = self.node
        if icon == nil or #highlight == 0 then
            return 0
        end
        if self.heading.position == 'right' then
            self.marks:add_over('head_icon', node, {
                priority = 1000,
                virt_text = { { icon, highlight } },
                virt_text_pos = 'eol',
            })
            return 1 + Str.width(icon)
        else
            local added = true
            for row = node.start_row, node.end_row - 1 do
                local added_row = self.marks:add('head_icon', row, node.start_col, {
                    end_row = row,
                    end_col = node.end_col,
                    virt_text = { { row == node.start_row and icon or Str.pad(Str.width(icon)), highlight } },
                    virt_text_pos = 'inline',
                })
                added = added and added_row
            end
            return added and Str.width(icon) or 0
        end
    end
end

---@private
---@param icon_width integer
---@return render.md.width.Heading
function Render:width(icon_width)
    local width = icon_width
    if self.data.atx then
        width = width + self.context:width(self.node:child('inline'))
    else
        width = width + vim.fn.max(Iter.list.map(self.node:lines(), Str.width))
    end
    local left_padding = self.context:resolve_offset(self.data.left_pad, width)
    local right_padding = self.context:resolve_offset(self.data.right_pad, width)
    width = math.max(left_padding + width + right_padding, self.data.min_width)
    ---@type render.md.width.Heading
    return {
        margin = self.context:resolve_offset(self.data.left_margin, width),
        padding = left_padding,
        content = width,
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
        win_col = width.margin + width.content + self:indent_size(self.data.level)
        table.insert(padding, self:pad(vim.o.columns * 2))
    end
    for row = self.node.start_row, self.node.end_row - 1 do
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
---@param position 'above'|'below'
---@param icon string
---@param row integer
function Render:border(width, position, icon, row)
    if not self.data.border then
        return
    end

    local foreground = self.data.foreground
    local background = self.data.background and colors.bg_to_fg(self.data.background)
    local prefix = self.heading.border_prefix and self.data.level or 0
    local total_width = self.data.width == 'block' and width.content or vim.o.columns

    local line = {
        self:pad(width.margin),
        { icon:rep(width.padding), background },
        { icon:rep(prefix), foreground },
        { icon:rep(total_width - width.padding - prefix), background },
    }

    local virtual = self.heading.border_virtual
    local target_line = self.node:line(position, 1)
    local line_available = target_line ~= nil and Str.width(target_line) == 0

    if not virtual and line_available and row ~= self.context.last_heading then
        self.marks:add('head_border', row, 0, {
            virt_text = line,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = row
    else
        self.marks:add(false, self.node.start_row, 0, {
            virt_lines = { vim.list_extend(self:indent_line(true, self.data.level), line) },
            virt_lines_above = position == 'above',
        })
    end
end

---@private
---@param width render.md.width.Heading
function Render:left_pad(width)
    local virt_text = {}
    if width.margin > 0 then
        table.insert(virt_text, self:pad(width.margin))
    end
    if width.padding > 0 then
        table.insert(virt_text, self:pad(width.padding, self.data.background))
    end
    if #virt_text == 0 then
        return
    end
    for row = self.node.start_row, self.node.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = virt_text,
            virt_text_pos = 'inline',
        })
    end
end

---@private
function Render:conceal_underline()
    self.marks:add_over(true, self.data.marker, { conceal = '' })
end

return Render
