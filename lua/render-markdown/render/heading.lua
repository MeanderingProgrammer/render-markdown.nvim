local Base = require('render-markdown.render.base')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.heading.Data
---@field atx boolean
---@field marker render.md.Node
---@field level integer
---@field icon? string
---@field sign? string
---@field fg? string
---@field bg? string
---@field width render.md.heading.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field border boolean

---@class render.md.heading.Box
---@field padding integer
---@field content integer
---@field margin integer

---@class render.md.render.Heading: render.md.Render
---@field private info render.md.heading.Config
---@field private data render.md.heading.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.heading
    if self.context:skip(self.info) then
        return false
    end
    if self.context.conceal:hidden(self.node) then
        return false
    end
    local atx, marker, level
    if self.node.type == 'atx_heading' and self.info.atx then
        atx = true
        marker = assert(self.node:child_at(0), 'atx heading missing marker')
        level = Str.level(marker.text)
    elseif self.node.type == 'setext_heading' and self.info.setext then
        atx = false
        marker = assert(self.node:child_at(1), 'ext heading missing underline')
        level = marker.type == 'setext_h1_underline' and 1 or 2
    else
        return false
    end
    local custom = self:custom()
    self.data = {
        atx = atx,
        marker = marker,
        level = level,
        icon = custom.icon or self:get_icon(self.info.icons, level),
        sign = List.cycle(self.info.signs, level),
        fg = custom.foreground or List.clamp(self.info.foregrounds, level),
        bg = custom.background or List.clamp(self.info.backgrounds, level),
        width = List.clamp(self.info.width, level) or 'full',
        left_margin = List.clamp(self.info.left_margin, level) or 0,
        left_pad = List.clamp(self.info.left_pad, level) or 0,
        right_pad = List.clamp(self.info.right_pad, level) or 0,
        min_width = List.clamp(self.info.min_width, level) or 0,
        border = List.clamp(self.info.border, level) or false,
    }
    return true
end

---@private
---@return render.md.heading.Custom
function Render:custom()
    for _, custom in pairs(self.info.custom) do
        if self.node.text:find(custom.pattern) then
            return custom
        end
    end
    return {}
end

---@private
---@param values render.md.heading.Icons
---@param level integer
---@return string?
function Render:get_icon(values, level)
    if type(values) == 'function' then
        return values({
            level = level,
            sections = self.node:sections(),
        })
    else
        return List.cycle(values, level)
    end
end

function Render:render()
    self:sign(self.info.sign, self.data.sign, self.data.fg)
    local box = self:box(self:icon())
    self:background(box)
    self:padding(box)
    if self.data.atx then
        self:border(box, true)
        self:border(box, false)
    else
        self.marks:over(true, self.data.marker, { conceal = '' })
        self.marks:over(true, self.data.marker, { conceal_lines = '' })
    end
end

---@private
---@return integer
function Render:icon()
    local icon, highlight = self.data.icon, {}
    if self.data.fg then
        highlight[#highlight + 1] = self.data.fg
    end
    if self.data.bg then
        highlight[#highlight + 1] = self.data.bg
    end
    if self.data.atx then
        local marker = self.data.marker
        -- add 1 to account for space after last `#`
        local width = self.context:width(marker) + 1
        if not icon or #highlight == 0 then
            return width
        end
        if self.info.position == 'right' then
            self.marks:over(true, marker, { conceal = '' }, { 0, 0, 0, 1 })
            self.marks:start('head_icon', marker, {
                priority = 1000,
                virt_text = { { icon, highlight } },
                virt_text_pos = 'eol',
            })
            return 1 + Str.width(icon)
        else
            local padding = width - Str.width(icon)
            if self.info.position == 'inline' or padding < 0 then
                local added = self.marks:over('head_icon', marker, {
                    virt_text = { { icon, highlight } },
                    virt_text_pos = 'inline',
                    conceal = '',
                }, { 0, 0, 0, 1 })
                return added and Str.width(icon) or width
            else
                self.marks:over('head_icon', marker, {
                    virt_text = { { Str.pad(padding) .. icon, highlight } },
                    virt_text_pos = 'overlay',
                })
                return width
            end
        end
    else
        local node = self.node
        if not icon or #highlight == 0 then
            return 0
        end
        if self.info.position == 'right' then
            self.marks:start('head_icon', node, {
                priority = 1000,
                virt_text = { { icon, highlight } },
                virt_text_pos = 'eol',
            })
            return 1 + Str.width(icon)
        else
            local added = true
            for row = node.start_row, node.end_row - 1 do
                local start = row == node.start_row
                local text = start and icon or Str.pad(Str.width(icon))
                added = added
                    and self.marks:add('head_icon', row, node.start_col, {
                        virt_text = { { text, highlight } },
                        virt_text_pos = 'inline',
                    })
            end
            return added and Str.width(icon) or 0
        end
    end
end

---@private
---@param icon integer
---@return render.md.heading.Box
function Render:box(icon)
    local width = icon
    if self.data.atx then
        width = width + self.context:width(self.node:child('inline'))
    else
        width = width + vim.fn.max(self.node:widths())
    end
    local left = self.context:percent(self.data.left_pad, width)
    local right = self.context:percent(self.data.right_pad, width)
    width = math.max(left + width + right, self.data.min_width)
    ---@type render.md.heading.Box
    return {
        padding = left,
        content = width,
        margin = self.context:percent(self.data.left_margin, width),
    }
end

---@private
---@param box render.md.heading.Box
function Render:background(box)
    local highlight = self.data.bg
    if not highlight then
        return
    end
    local win_col, padding = 0, {}
    if self.data.width == 'block' then
        win_col = box.margin + box.content + self:indent_size(self.data.level)
        self:append(padding, vim.o.columns * 2)
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
---@param box render.md.heading.Box
function Render:padding(box)
    local line = self:append({}, box.margin)
    self:append(line, box.padding, self.data.bg)
    if #line == 0 then
        return
    end
    for row = self.node.start_row, self.node.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = line,
            virt_text_pos = 'inline',
        })
    end
end

---@private
---@param box render.md.heading.Box
---@param above boolean
function Render:border(box, above)
    if not self.data.border then
        return
    end

    local fg = self.data.fg
    local bg = self.data.bg and colors.bg_as_fg(self.data.bg)
    local prefix = self.info.border_prefix and self.data.level or 0
    local width = self.data.width == 'block' and box.content or vim.o.columns
    local icon = above and self.info.above or self.info.below

    local line = self:append({}, box.margin)
    self:append(line, icon:rep(box.padding), bg)
    self:append(line, icon:rep(prefix), fg)
    self:append(line, icon:rep(width - box.padding - prefix), bg)

    local virtual = self.info.border_virtual
    local row, target = self.node:line(above and 'above' or 'below', 1)
    local available = target and Str.width(target) == 0

    if not virtual and available and row ~= self.context.last_heading then
        self.marks:add('head_border', row, 0, {
            virt_text = line,
            virt_text_pos = 'overlay',
        })
        self.context.last_heading = row
    else
        self.marks:add(false, self.node.start_row, 0, {
            virt_lines = {
                vim.list_extend(self:indent_line(true, self.data.level), line),
            },
            virt_lines_above = above,
        })
    end
end

return Render
