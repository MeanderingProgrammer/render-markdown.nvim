local Base = require('render-markdown.render.base')
local Icons = require('render-markdown.lib.icons')
local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.data.Code
---@field col integer
---@field width integer
---@field max_width integer
---@field empty_rows integer[]
---@field language_padding integer
---@field padding integer
---@field margin integer
---@field indent integer

---@class render.md.render.Code: render.md.Renderer
---@field private code render.md.Code
---@field private data render.md.data.Code
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.code = self.config.code
    if self.context:skip(self.code) then
        return false
    end
    if self.code.style == 'none' then
        return false
    end
    -- Do not attempt to render single line code block
    if self.node.end_row - self.node.start_row <= 1 then
        return false
    end

    local widths = Iter.list.map(self.node:lines(), Str.width)
    local max_width = vim.fn.max(widths)
    local empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(empty_rows, self.node.start_row + row - 1)
        end
    end

    local language_padding = self:offset(self.code.language_pad, max_width, self.code.position)
    local left_padding = self:offset(self.code.left_pad, max_width, 'left')
    local right_padding = self:offset(self.code.right_pad, max_width, 'right')
    max_width = math.max(widths[1] + language_padding, left_padding + max_width + right_padding, self.code.min_width)

    self.data = {
        col = self.node.start_col,
        width = self.code.width == 'block' and max_width or vim.o.columns,
        max_width = max_width,
        empty_rows = empty_rows,
        language_padding = language_padding,
        padding = left_padding,
        margin = self:offset(self.code.left_margin, max_width, 'left'),
        indent = self:indent_size(),
    }

    return true
end

---@private
---@param offset integer
---@param width integer
---@param position render.md.code.Position
---@return integer
function Render:offset(offset, width, position)
    if offset <= 0 then
        return 0
    end
    local result = self.context:to_width(offset, width)
    if position == 'left' and self.node.text:find('\t') ~= nil then
        local tab_size = self.context:tab_size()
        -- Rounds to the next multiple of tab_size
        result = math.ceil(result / tab_size) * tab_size
    end
    return result
end

function Render:render()
    local info = self.node:child('info_string')
    local language = info ~= nil and info:child('language') or nil
    self.marks:over(true, language, { conceal = '' })

    local start_row = self.node.start_row
    local top = self.node:child('fenced_code_block_delimiter', start_row)
    self.marks:over(true, top, { conceal = '' })

    local end_row = self.node.end_row - 1
    local bottom = self.node:child('fenced_code_block_delimiter', end_row)
    self.marks:over(true, bottom, { conceal = '' })

    local icon = self:language(language, top)
    local more_info = info ~= nil and language ~= nil and info.end_col > language.end_col
    self:border(top, true, not icon and not more_info)
    self:border(bottom, false, true)

    local background = self:background_enabled(language)
    if background then
        self:background(start_row + 1, end_row - 1)
    end
    self:left_pad(background)
end

---@private
---@param language? render.md.Node
---@param delim? render.md.Node
---@return boolean
function Render:language(language, delim)
    if not vim.tbl_contains({ 'language', 'full' }, self.code.style) then
        return false
    end
    if language == nil or delim == nil then
        return false
    end

    local padding = self.data.language_padding

    local icon, icon_highlight = Icons.get(language.text)
    if self.code.highlight_language ~= nil then
        icon_highlight = self.code.highlight_language
    end

    self:sign(self.code.sign, icon, icon_highlight)

    local text = ''
    if self.code.language_icon and icon ~= nil then
        text = text .. icon .. ' '
    end
    if self.code.language_name then
        text = text .. language.text
    end
    if #text == 0 then
        return false
    end

    local highlight = { icon_highlight or self.code.highlight_fallback }
    table.insert(highlight, self.code.highlight)

    if self.code.position == 'left' then
        text = Str.pad(padding) .. text
        -- Code blocks can pick up varying amounts of leading white space.
        -- This is lumped into the delimiter node and needs to be handled.
        local spaces = Str.spaces('start', delim.text)
        local width = self.context:width(delim)
        if self.context.conceal:enabled() then
            width = self.context.conceal:width('')
        end
        text = Str.pad(spaces - width) .. text
        return self.marks:start('code_language', language, {
            virt_text = { { text, highlight } },
            virt_text_pos = 'inline',
        })
    else
        local start = self.data.max_width - padding
        if self.code.width == 'block' then
            start = start - Str.width(text)
        end
        return self.marks:add('code_language', language.start_row, 0, {
            virt_text = { { text, highlight } },
            virt_text_win_col = start + self.data.indent,
        })
    end
end

---@private
---@param delim? render.md.Node
---@param above boolean
---@param empty boolean
function Render:border(delim, above, empty)
    if self.code.border == 'none' or delim == nil then
        -- skip
    elseif self.code.border == 'thick' or not empty then
        self:background(delim.start_row, delim.start_row)
    elseif self.code.border == 'hide' and self.marks:over(true, delim, { conceal_lines = '' }) then
        -- successfully added
    else
        local width, highlight = self.data.width - self.data.col, self.code.highlight
        local border = above and self.code.above or self.code.below
        local line = { { border:rep(width), colors.bg_to_fg(highlight) } }
        self.marks:add('code_border', delim.start_row, self.data.col, {
            virt_text = line,
            virt_text_pos = 'overlay',
        })
    end
end

---@private
---@param language? render.md.Node
---@return boolean
function Render:background_enabled(language)
    if not vim.tbl_contains({ 'normal', 'full' }, self.code.style) then
        return false
    end
    local disable = self.code.disable_background
    if type(disable) == 'table' then
        return language == nil or not vim.tbl_contains(disable, language.text)
    else
        return not disable
    end
end

---@private
---@param start_row integer
---@param end_row integer
function Render:background(start_row, end_row)
    local win_col, padding = 0, {}
    if self.code.width == 'block' then
        win_col = self.data.margin + self.data.max_width + self.data.indent
        self:append(padding, vim.o.columns * 2)
    end
    for row = start_row, end_row do
        self.marks:add('code_background', row, self.data.col, {
            end_row = row + 1,
            hl_group = self.code.highlight,
            hl_eol = true,
        })
        if win_col > 0 and #padding > 0 then
            -- Overwrite anything beyond width with padding highlight
            self.marks:add('code_background', row, self.data.col, {
                priority = 0,
                virt_text = padding,
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param background boolean
function Render:left_pad(background)
    local margin, padding = self.data.margin, self.data.padding
    if (self.data.col == 0 or #self.data.empty_rows == 0) and margin <= 0 and padding <= 0 then
        return
    end

    -- Use lowest priority (0) to include all other marks in padding when code block is at edge
    -- Use medium priority (1000) to include border marks while likely avoiding other plugin
    local priority = self.data.col == 0 and 0 or 1000
    local highlight = background and self.code.highlight or nil

    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    for row = start_row, end_row do
        local line = {}
        if vim.tbl_contains(self.data.empty_rows, row) then
            self:append(line, self.data.col)
        end
        self:append(line, margin)
        if row > start_row and row < end_row then
            self:append(line, padding, highlight)
        end
        if #line > 0 then
            self.marks:add(false, row, self.data.col, {
                priority = priority,
                virt_text = line,
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
