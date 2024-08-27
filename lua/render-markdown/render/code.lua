local colors = require('render-markdown.colors')
local icons = require('render-markdown.core.icons')
local str = require('render-markdown.core.str')
local util = require('render-markdown.render.util')

---@class render.md.render.Code: render.md.Renderer
---@field private code render.md.Code
---@field private col integer
---@field private start_row integer
---@field private end_row integer
---@field private code_info? render.md.NodeInfo
---@field private language_info? render.md.NodeInfo
---@field private language? string
---@field private width integer
---@field private empty_rows integer[]
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
    self.code = self.config.code
    if not self.code.enabled or self.code.style == 'none' then
        return false
    end

    -- Do not attempt to render single line code block
    self.col, self.start_row, self.end_row = self.info.start_col, self.info.start_row, self.info.end_row
    if self.end_row - self.start_row <= 1 then
        return false
    end

    self.code_info = self.info:child('info_string')
    self.language_info = self.code_info ~= nil and self.code_info:child('language') or nil
    self.language = (self.language_info or {}).text

    -- Account for language padding in first row
    local widths = vim.tbl_map(str.width, self.info:lines())
    widths[1] = widths[1] + self.code.language_pad

    self.width = self.code.left_pad + vim.fn.max(widths) + self.code.right_pad
    self.width = math.max(self.width, self.code.min_width)

    self.empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(self.empty_rows, self.start_row + row - 1)
        end
    end

    return true
end

function Render:render()
    local disabled_language = vim.tbl_contains(self.code.disable_background, self.language)
    local add_background = vim.tbl_contains({ 'normal', 'full' }, self.code.style) and not disabled_language

    local icon_added = self:language_hint(add_background)
    if add_background then
        self:background(icon_added)
    end
    if icon_added then
        self.start_row = self.start_row + 1
    end
    self:left_pad(add_background)
end

---@private
---@param add_background boolean
---@return boolean
function Render:language_hint(add_background)
    if not vim.tbl_contains({ 'language', 'full' }, self.code.style) then
        return false
    end
    local info = self.language_info
    if info == nil then
        return false
    end
    local icon, icon_highlight = icons.get(info.text)
    if icon == nil or icon_highlight == nil then
        return false
    end
    if self.code.sign then
        util.sign(self.config, self.marks, info, icon, icon_highlight)
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
            icon_text = str.pad(str.leading_spaces(self.info.text) + self.code.language_pad, icon_text .. info.text)
        end
        return self.marks:add(true, info.start_row, info.start_col, {
            virt_text = { { icon_text, highlight } },
            virt_text_pos = 'inline',
        })
    elseif self.code.position == 'right' then
        local icon_text = icon .. ' ' .. info.text
        local win_col = self.width - self.code.language_pad
        if self.code.width == 'block' then
            win_col = win_col - str.width(icon_text)
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
    local width = self.code.width == 'block' and self.width or self.context:get_width()

    if self.code.border == 'thin' then
        local border_width = width - self.col
        if not icon_added and self.context:hidden(self.code_info) and self:delim_hidden(self.start_row) then
            self.marks:add(true, self.start_row, self.col, {
                virt_text = { { self.code.above:rep(border_width), colors.inverse(self.code.highlight) } },
                virt_text_pos = 'overlay',
            })
            self.start_row = self.start_row + 1
        end
        if self:delim_hidden(self.end_row - 1) then
            self.marks:add(true, self.end_row - 1, self.col, {
                virt_text = { { self.code.below:rep(border_width), colors.inverse(self.code.highlight) } },
                virt_text_pos = 'overlay',
            })
            self.end_row = self.end_row - 1
        end
    end

    local padding = str.spaces(vim.o.columns * 2)
    for row = self.start_row, self.end_row - 1 do
        self.marks:add(false, row, self.col, {
            end_row = row + 1,
            hl_group = self.code.highlight,
            hl_eol = true,
        })
        if self.code.width == 'block' then
            -- Overwrite anything beyond width with Normal
            self.marks:add(false, row, self.col, {
                priority = 0,
                virt_text = { { padding, 'Normal' } },
                virt_text_win_col = width,
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
function Render:left_pad(add_background)
    if (self.col == 0 or #self.empty_rows == 0) and self.code.left_pad <= 0 then
        return
    end

    -- Use low priority to include other marks in padding when code block is at edge
    local priority = self.col == 0 and 0 or nil
    local outer_text = { str.spaces(self.col), 'Normal' }
    local left_text = { str.spaces(self.code.left_pad), add_background and self.code.highlight or 'Normal' }

    for row = self.start_row, self.end_row - 1 do
        local virt_text = {}
        if self.col > 0 and vim.tbl_contains(self.empty_rows, row) then
            table.insert(virt_text, outer_text)
        end
        if self.code.left_pad > 0 then
            table.insert(virt_text, left_text)
        end
        if #virt_text > 0 then
            self.marks:add(false, row, self.col, {
                priority = priority,
                virt_text = virt_text,
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
