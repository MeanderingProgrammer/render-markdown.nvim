local colors = require('render-markdown.colors')
local icons = require('render-markdown.core.icons')
local str = require('render-markdown.core.str')
local util = require('render-markdown.render.util')

---@class render.md.code.Code
---@field col integer
---@field start_row integer
---@field end_row integer
---@field leading_spaces integer
---@field empty_rows integer[]
---@field longest_line integer
---@field width integer
---@field code_info_hidden boolean
---@field language_info? render.md.NodeInfo
---@field language? string
---@field start_delim_hidden boolean
---@field end_delim_hidden boolean

---@class render.md.parser.Code
local Parser = {}

---@private
---@param config render.md.Code
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.code.Code?
function Parser.parse(config, context, info)
    -- Do not attempt to render single line code block
    if info.end_row - info.start_row <= 1 then
        return nil
    end

    -- Account for language padding in first row
    local widths = vim.tbl_map(str.width, info:lines())
    widths[1] = widths[1] + config.language_pad
    local longest_line, width = Parser.get_width(config, context, widths)

    local code_info = info:child('info_string', info.start_row)
    local language_info = code_info ~= nil and code_info:child('language', info.start_row) or nil

    ---@type render.md.code.Code
    return {
        col = info.start_col,
        start_row = info.start_row,
        end_row = info.end_row,
        leading_spaces = str.leading_spaces(info.text),
        empty_rows = Parser.get_empty_rows(info.start_row, widths),
        longest_line = longest_line,
        width = width,
        code_info_hidden = context:hidden(code_info),
        language_info = language_info,
        language = (language_info or {}).text,
        start_delim_hidden = context:hidden(info:child('fenced_code_block_delimiter', info.start_row)),
        end_delim_hidden = context:hidden(info:child('fenced_code_block_delimiter', info.end_row - 1)),
    }
end

---@private
---@param start_row integer
---@param widths integer[]
---@return integer[]
function Parser.get_empty_rows(start_row, widths)
    local empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(empty_rows, start_row + row - 1)
        end
    end
    return empty_rows
end

---@private
---@param config render.md.Code
---@param context render.md.Context
---@param widths integer[]
---@return integer, integer
function Parser.get_width(config, context, widths)
    local longest_line = config.left_pad + vim.fn.max(widths) + config.right_pad
    local width = math.max(longest_line, config.min_width)
    if config.width == 'block' then
        return width, width
    else
        return width, context:get_width()
    end
end

---@class render.md.render.Code: render.md.Renderer
---@field private config render.md.Code
local Render = {}
Render.__index = Render

---@param buf integer
---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@return render.md.render.Code
function Render.new(buf, marks, config, context)
    local self = setmetatable({}, Render)
    self.buf = buf
    self.marks = marks
    self.config = config.code
    self.context = context
    return self
end

---@param info render.md.NodeInfo
function Render:render(info)
    if not self.config.enabled or self.config.style == 'none' then
        return
    end

    local code = Parser.parse(self.config, self.context, info)
    if code == nil then
        return
    end

    local disabled_language = vim.tbl_contains(self.config.disable_background, code.language)
    local add_background = vim.tbl_contains({ 'normal', 'full' }, self.config.style) and not disabled_language

    local icon_added = self:language(code, add_background)
    if add_background then
        self:background(code, icon_added)
    end
    if icon_added then
        code.start_row = code.start_row + 1
    end
    self:left_pad(code, add_background)
end

---@private
---@param code render.md.code.Code
---@param add_background boolean
---@return boolean
function Render:language(code, add_background)
    if not vim.tbl_contains({ 'language', 'full' }, self.config.style) then
        return false
    end
    local info = code.language_info
    if info == nil then
        return false
    end
    local icon, icon_highlight = icons.get(info.text)
    if icon == nil or icon_highlight == nil then
        return false
    end
    if self.config.sign then
        util.sign(self.buf, self.marks, info, icon, icon_highlight)
    end
    local highlight = { icon_highlight }
    if add_background then
        table.insert(highlight, self.config.highlight)
    end
    if self.config.position == 'left' then
        local icon_text = icon .. ' '
        if self.context:hidden(info) then
            -- Code blocks will pick up varying amounts of leading white space depending on the
            -- context they are in. This gets lumped into the delimiter node and as a result,
            -- after concealing, the extmark will be left shifted. Logic below accounts for this.
            icon_text = str.pad(code.leading_spaces + self.config.language_pad, icon_text .. info.text)
        end
        return self.marks:add(true, info.start_row, info.start_col, {
            virt_text = { { icon_text, highlight } },
            virt_text_pos = 'inline',
        })
    elseif self.config.position == 'right' then
        local icon_text = icon .. ' ' .. info.text
        local win_col = code.longest_line - self.config.language_pad
        if self.config.width == 'block' then
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
---@param code render.md.code.Code
---@param icon_added boolean
function Render:background(code, icon_added)
    if self.config.border == 'thin' then
        local border_width = code.width - code.col
        if not icon_added and code.code_info_hidden and code.start_delim_hidden then
            self.marks:add(true, code.start_row, code.col, {
                virt_text = { { self.config.above:rep(border_width), colors.inverse(self.config.highlight) } },
                virt_text_pos = 'overlay',
            })
            code.start_row = code.start_row + 1
        end
        if code.end_delim_hidden then
            self.marks:add(true, code.end_row - 1, code.col, {
                virt_text = { { self.config.below:rep(border_width), colors.inverse(self.config.highlight) } },
                virt_text_pos = 'overlay',
            })
            code.end_row = code.end_row - 1
        end
    end

    local padding = str.spaces(vim.o.columns * 2)
    for row = code.start_row, code.end_row - 1 do
        self.marks:add(false, row, code.col, {
            end_row = row + 1,
            hl_group = self.config.highlight,
            hl_eol = true,
        })
        if self.config.width == 'block' then
            -- Overwrite anything beyond width with Normal
            self.marks:add(false, row, code.col, {
                priority = 0,
                virt_text = { { padding, 'Normal' } },
                virt_text_win_col = code.width,
            })
        end
    end
end

---@private
---@param code render.md.code.Code
---@param add_background boolean
function Render:left_pad(code, add_background)
    if (code.col == 0 or #code.empty_rows == 0) and self.config.left_pad <= 0 then
        return
    end

    -- Use low priority to include other marks in padding when code block is at edge
    local priority = code.col == 0 and 0 or nil
    local outer_text = { str.spaces(code.col), 'Normal' }
    local left_text = { str.spaces(self.config.left_pad), add_background and self.config.highlight or 'Normal' }

    for row = code.start_row, code.end_row - 1 do
        local virt_text = {}
        if code.col > 0 and vim.tbl_contains(code.empty_rows, row) then
            table.insert(virt_text, outer_text)
        end
        if self.config.left_pad > 0 then
            table.insert(virt_text, left_text)
        end
        if #virt_text > 0 then
            self.marks:add(false, row, code.col, {
                priority = priority,
                virt_text = virt_text,
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
