local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.core.iter')
local colors = require('render-markdown.colors')
local icons = require('render-markdown.core.icons')
local str = require('render-markdown.core.str')

---@class render.md.data.Code
---@field col integer
---@field start_row integer
---@field end_row integer
---@field code_info? render.md.NodeInfo
---@field language_info? render.md.NodeInfo
---@field language? string
---@field margin integer
---@field language_padding integer
---@field padding integer
---@field max_width integer
---@field empty_rows integer[]
---@field indent integer

---@class render.md.render.Code: render.md.Renderer
---@field private code render.md.Code
---@field private data render.md.data.Code
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
    self.code = self.config.code
    if not self.code.enabled or self.code.style == 'none' then
        return false
    end
    -- Do not attempt to render single line code block
    if self.info.end_row - self.info.start_row <= 1 then
        return false
    end

    local code_info = self.info:child('info_string')
    local language_info = code_info ~= nil and code_info:child('language') or nil

    local widths = Iter.list.map(self.info:lines(), str.width)

    local empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(empty_rows, self.info.start_row + row - 1)
        end
    end

    local max_width = vim.fn.max(widths)
    local language_padding = self.context:resolve_offset(self.code.language_pad, max_width)
    local left_padding = self.context:resolve_offset(self.code.left_pad, max_width)
    local right_padding = self.context:resolve_offset(self.code.right_pad, max_width)
    max_width = math.max(widths[1] + language_padding, left_padding + max_width + right_padding, self.code.min_width)

    self.data = {
        col = self.info.start_col,
        start_row = self.info.start_row,
        end_row = self.info.end_row,
        code_info = code_info,
        language_info = language_info,
        language = (language_info or {}).text,
        margin = self.context:resolve_offset(self.code.left_margin, max_width),
        language_padding = language_padding,
        padding = left_padding,
        max_width = max_width,
        empty_rows = empty_rows,
        indent = self:indent(),
    }

    return true
end

function Render:render()
    local disabled_language = vim.tbl_contains(self.code.disable_background, self.data.language)
    local add_background = vim.tbl_contains({ 'normal', 'full' }, self.code.style) and not disabled_language

    local icon_added = self:language(add_background)
    if add_background then
        self:background(icon_added)
    end
    self:left_pad(add_background, icon_added)
end

---@private
---@param add_background boolean
---@return boolean
function Render:language(add_background)
    if not vim.tbl_contains({ 'language', 'full' }, self.code.style) then
        return false
    end
    local info = self.data.language_info
    if info == nil then
        return false
    end
    local icon, icon_highlight = icons.get(info.text)
    if self.code.highlight_language ~= nil then
        icon_highlight = self.code.highlight_language
    end
    if icon == nil or icon_highlight == nil then
        return false
    end
    if self.code.sign then
        self:sign(icon, icon_highlight)
    end
    local highlight = { icon_highlight }
    if add_background then
        table.insert(highlight, self.code.highlight)
    end
    if self.code.position == 'left' then
        local icon_text = icon .. ' '
        if self.context:hidden(info) then
            -- Code blocks will pick up varying amounts of leading white space depending on the
            -- context they are in. This gets lumped into the delimiter node and as a result,
            -- after concealing, the extmark will be left shifted. Logic below accounts for this.
            local padding = str.spaces('start', self.info.text) + self.data.language_padding
            icon_text = str.pad(padding) .. icon_text .. info.text
        end
        return self.marks:add(true, info.start_row, info.start_col, {
            virt_text = { { icon_text, highlight } },
            virt_text_pos = 'inline',
        })
    elseif self.code.position == 'right' then
        local icon_text = icon .. ' ' .. info.text
        local win_col = self.data.max_width - self.data.language_padding
        if self.code.width == 'block' then
            win_col = win_col - str.width(icon_text) + self.data.indent
        end
        return self.marks:add(true, info.start_row, 0, {
            virt_text = { { icon_text, highlight } },
            virt_text_win_col = win_col,
        })
    else
        return false
    end
end

---@private
---@param icon_added boolean
function Render:background(icon_added)
    local width = self.code.width == 'block' and self.data.max_width or self.context:get_width()

    if self.code.border == 'thin' then
        ---@param row integer
        ---@param icon string
        local function add_border(row, icon)
            local virt_text = {}
            if self.data.margin > 0 then
                table.insert(virt_text, { str.pad(self.data.margin), self.config.padding.highlight })
            end
            table.insert(virt_text, { icon:rep(width - self.data.col), colors.bg_to_fg(self.code.highlight) })
            self.marks:add(true, row, self.data.col, {
                virt_text = virt_text,
                virt_text_pos = 'overlay',
            })
        end
        if not icon_added and self.context:hidden(self.data.code_info) and self:delim_hidden(self.data.start_row) then
            add_border(self.data.start_row, self.code.above)
            self.data.start_row = self.data.start_row + 1
        end
        if self:delim_hidden(self.data.end_row - 1) then
            add_border(self.data.end_row - 1, self.code.below)
            self.data.end_row = self.data.end_row - 1
        end
    end

    local win_col, padding = 0, {}
    if self.code.width == 'block' then
        win_col = self.data.margin + width + self.data.indent
        table.insert(padding, { str.pad(vim.o.columns * 2), self.config.padding.highlight })
    end
    for row = self.data.start_row, self.data.end_row - 1 do
        self.marks:add(false, row, self.data.col, {
            end_row = row + 1,
            hl_group = self.code.highlight,
            hl_eol = true,
        })
        if win_col > 0 and #padding > 0 then
            -- Overwrite anything beyond width with padding highlight
            self.marks:add(false, row, self.data.col, {
                priority = 0,
                virt_text = padding,
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param row integer
---@return boolean
function Render:delim_hidden(row)
    return self.context:hidden(self.info:child('fenced_code_block_delimiter', row))
end

---@private
---@param add_background boolean
---@param icon_added boolean
function Render:left_pad(add_background, icon_added)
    local margin, padding = self.data.margin, self.data.padding
    if (self.data.col == 0 or #self.data.empty_rows == 0) and margin <= 0 and padding <= 0 then
        return
    end

    -- Use low priority to include other marks in padding when code block is at edge
    local priority = self.data.col == 0 and 0 or nil
    local fill_text = { str.pad(self.data.col), self.config.padding.highlight }
    local margin_text = { str.pad(margin), self.config.padding.highlight }
    local background = add_background and self.code.highlight or self.config.padding.highlight
    local padding_text = { str.pad(padding), background }

    for row = self.data.start_row, self.data.end_row - 1 do
        local virt_text = {}
        if self.data.col > 0 and vim.tbl_contains(self.data.empty_rows, row) then
            table.insert(virt_text, fill_text)
        end
        if margin > 0 then
            table.insert(virt_text, margin_text)
        end
        local skip_padding = row == self.data.start_row and icon_added
        if not skip_padding and padding > 0 then
            table.insert(virt_text, padding_text)
        end
        if #virt_text > 0 then
            self.marks:add(false, row, self.data.col, {
                priority = priority,
                virt_text = virt_text,
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
