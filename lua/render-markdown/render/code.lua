local Base = require('render-markdown.render.base')
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

    -- Account for language padding in first row
    local widths = vim.tbl_map(str.width, self.info:lines())
    widths[1] = widths[1] + self.code.language_pad
    local max_width = self.code.left_pad + vim.fn.max(widths) + self.code.right_pad
    local empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(empty_rows, self.info.start_row + row - 1)
        end
    end

    self.data = {
        col = self.info.start_col,
        start_row = self.info.start_row,
        end_row = self.info.end_row,
        code_info = code_info,
        language_info = language_info,
        language = (language_info or {}).text,
        max_width = math.max(max_width, self.code.min_width),
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
    if icon_added then
        self.data.start_row = self.data.start_row + 1
    end
    self:left_pad(add_background)
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
            icon_text = str.pad(str.spaces('start', self.info.text) + self.code.language_pad) .. icon_text .. info.text
        end
        return self.marks:add(true, info.start_row, info.start_col, {
            virt_text = { { icon_text, highlight } },
            virt_text_pos = 'inline',
        })
    elseif self.code.position == 'right' then
        local icon_text = icon .. ' ' .. info.text
        local win_col = self.data.max_width - self.code.language_pad
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
        local border_width = width - self.data.col
        if not icon_added and self.context:hidden(self.data.code_info) and self:delim_hidden(self.data.start_row) then
            self.marks:add(true, self.data.start_row, self.data.col, {
                virt_text = { { self.code.above:rep(border_width), colors.inverse_bg(self.code.highlight) } },
                virt_text_pos = 'overlay',
            })
            self.data.start_row = self.data.start_row + 1
        end
        if self:delim_hidden(self.data.end_row - 1) then
            self.marks:add(true, self.data.end_row - 1, self.data.col, {
                virt_text = { { self.code.below:rep(border_width), colors.inverse_bg(self.code.highlight) } },
                virt_text_pos = 'overlay',
            })
            self.data.end_row = self.data.end_row - 1
        end
    end

    local padding = str.pad(vim.o.columns * 2)
    for row = self.data.start_row, self.data.end_row - 1 do
        self.marks:add(false, row, self.data.col, {
            end_row = row + 1,
            hl_group = self.code.highlight,
            hl_eol = true,
        })
        if self.code.width == 'block' then
            -- Overwrite anything beyond width with padding highlight
            self.marks:add(false, row, self.data.col, {
                priority = 0,
                virt_text = { { padding, self.config.padding.highlight } },
                virt_text_win_col = width + self.data.indent,
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
    if (self.data.col == 0 or #self.data.empty_rows == 0) and self.code.left_pad <= 0 then
        return
    end

    -- Use low priority to include other marks in padding when code block is at edge
    local priority = self.data.col == 0 and 0 or nil
    local outer_text = { str.pad(self.data.col), self.config.padding.highlight }
    local background = add_background and self.code.highlight or self.config.padding.highlight
    local left_text = { str.pad(self.code.left_pad), background }

    for row = self.data.start_row, self.data.end_row - 1 do
        local virt_text = {}
        if self.data.col > 0 and vim.tbl_contains(self.data.empty_rows, row) then
            table.insert(virt_text, outer_text)
        end
        if self.code.left_pad > 0 then
            table.insert(virt_text, left_text)
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
