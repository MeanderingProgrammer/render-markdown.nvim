local Base = require('render-markdown.render.base')
local Env = require('render-markdown.lib.env')
local Icons = require('render-markdown.integ.icons')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.code.Data
---@field width integer
---@field language integer
---@field padding integer
---@field margin integer
---@field indent integer

---@class render.md.render.Code: render.md.Render
---@field private info render.md.code.Config
---@field private data render.md.code.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.code
    if self.context:skip(self.info) then
        return false
    end
    if self.info.style == 'none' then
        return false
    end
    -- Do not attempt to render single line code block
    if self.node.end_row - self.node.start_row <= 1 then
        return false
    end

    local widths = self.node:widths()
    local width = vim.fn.max(widths)
    local language = self:offset(self.info.language_pad, width)
    local left = self:offset(self.info.left_pad, width)
    local right = self:offset(self.info.right_pad, width)
    width = math.max(
        widths[1] + language,
        left + width + right,
        self.info.min_width
    )

    self.data = {
        width = width,
        language = language,
        padding = left,
        margin = self:offset(self.info.left_margin, width),
        indent = self:indent_size(),
    }

    return true
end

---@private
---@param value integer
---@param used integer
---@return integer
function Render:offset(value, used)
    if value <= 0 then
        return 0
    end
    local result = self.context:percent(value, used)
    if self.node.text:find('\t') ~= nil then
        -- Rounds to the next multiple of tab size
        local tab_size = Env.buf.get(self.context.buf, 'tabstop')
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
    local more_info = info ~= nil
        and language ~= nil
        and info.end_col > language.end_col
    self:border(top, true, not icon and not more_info)
    self:border(bottom, false, true)

    local background = self:background_enabled(language)
    if background then
        self:background(start_row + 1, end_row - 1, self.info.highlight)
    end
    self:padding(background)
end

---@private
---@param language? render.md.Node
---@param delim? render.md.Node
---@return boolean
function Render:language(language, delim)
    if not vim.tbl_contains({ 'language', 'full' }, self.info.style) then
        return false
    end
    if language == nil or delim == nil then
        return false
    end

    local border_highlight = self.info.highlight_border
    local padding = self.data.language

    local icon, icon_highlight = Icons.get(language.text)
    if self.info.highlight_language ~= nil then
        icon_highlight = self.info.highlight_language
    end

    self:sign(self.info.sign, icon, icon_highlight)

    local text = ''
    if self.info.language_icon and icon ~= nil then
        text = text .. icon .. ' '
    end
    if self.info.language_name then
        text = text .. language.text
    end
    if #text == 0 then
        return false
    end

    local highlight = {}
    highlight[#highlight + 1] = (icon_highlight or self.info.highlight_fallback)
    if type(border_highlight) == 'string' then
        highlight[#highlight + 1] = border_highlight
    end

    if self.info.position == 'left' then
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
        local start = self.data.width - padding
        if self.info.width == 'block' then
            start = start - Str.width(text)
        end
        return self.marks:add('code_language', language.start_row, 0, {
            virt_text = { { text, highlight } },
            virt_text_win_col = start + self.data.indent,
        })
    end
end

---@private
---@param node? render.md.Node
---@param above boolean
---@param empty boolean
function Render:border(node, above, empty)
    local kind = self.info.border
    local highlight = self.info.highlight_border
    if kind == 'none' or type(highlight) == 'boolean' or node == nil then
        -- skip
    elseif kind == 'thick' or not empty then
        self:background(node.start_row, node.start_row, highlight)
    elseif
        kind == 'hide' and self.marks:over(true, node, { conceal_lines = '' })
    then
        -- successfully added
    else
        local row, col = node.start_row, self.node.start_col
        local border = above and self.info.above or self.info.below
        local width = self.info.width == 'block' and self.data.width - col
            or vim.o.columns
        self.marks:add('code_border', row, col, {
            virt_text = { { border:rep(width), colors.bg_as_fg(highlight) } },
            virt_text_pos = 'overlay',
        })
    end
end

---@private
---@param language? render.md.Node
---@return boolean
function Render:background_enabled(language)
    if not vim.tbl_contains({ 'normal', 'full' }, self.info.style) then
        return false
    end
    local disable = self.info.disable_background
    if type(disable) == 'boolean' then
        return not disable
    else
        return language == nil or not vim.tbl_contains(disable, language.text)
    end
end

---@private
---@param start_row integer
---@param end_row integer
---@param highlight string
function Render:background(start_row, end_row, highlight)
    local col, win_col, padding = self.node.start_col, 0, {}
    if self.info.width == 'block' then
        win_col = self.data.margin + self.data.width + self.data.indent
        self:append(padding, vim.o.columns * 2)
    end
    for row = start_row, end_row do
        self.marks:add('code_background', row, col, {
            end_row = row + 1,
            hl_group = highlight,
            hl_eol = true,
        })
        if win_col > 0 and #padding > 0 then
            -- Overwrite anything beyond width with padding highlight
            self.marks:add('code_background', row, col, {
                priority = 0,
                virt_text = padding,
                virt_text_win_col = win_col,
            })
        end
    end
end

---@private
---@param background boolean
function Render:padding(background)
    local col = self.node.start_col
    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    local empty, widths = {}, col == 0 and {} or self.node:widths()
    for i, width in ipairs(widths) do
        if width == 0 then
            empty[#empty + 1] = (start_row + i - 1)
        end
    end
    if #empty == 0 and self.data.margin <= 0 and self.data.padding <= 0 then
        return
    end

    -- Use lowest priority (0) to include all other marks in padding when code block is at edge
    -- Use medium priority (1000) to include border marks while likely avoiding other plugin
    local priority = col == 0 and 0 or 1000
    local highlight = background and self.info.highlight or nil

    for row = start_row, end_row do
        local line = {}
        if vim.tbl_contains(empty, row) then
            self:append(line, col)
        end
        self:append(line, self.data.margin)
        if row > start_row and row < end_row then
            self:append(line, self.data.padding, highlight)
        end
        if #line > 0 then
            self.marks:add(false, row, col, {
                priority = priority,
                virt_text = line,
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
