local Base = require('render-markdown.render.base')
local Icons = require('render-markdown.lib.icons')
local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.data.Code
---@field col integer
---@field code_node? render.md.Node
---@field language_node? render.md.Node
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

    local code_node = self.node:child('info_string')
    local language_node = code_node ~= nil and code_node:child('language') or nil

    local widths = Iter.list.map(self.node:lines(), Str.width)

    local empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(empty_rows, self.node.start_row + row - 1)
        end
    end

    local max_width = vim.fn.max(widths)
    local language_padding = self:offset(self.code.language_pad, max_width, self.code.position)
    local left_padding = self:offset(self.code.left_pad, max_width, 'left')
    local right_padding = self:offset(self.code.right_pad, max_width, 'right')
    max_width = math.max(widths[1] + language_padding, left_padding + max_width + right_padding, self.code.min_width)

    self.data = {
        col = self.node.start_col,
        code_node = code_node,
        language_node = language_node,
        language = (language_node or {}).text,
        margin = self:offset(self.code.left_margin, max_width, 'left'),
        language_padding = language_padding,
        padding = left_padding,
        max_width = max_width,
        empty_rows = empty_rows,
        indent = self:indent(),
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
    local result = self.context:resolve_offset(offset, width)
    if position == 'left' and self.node.text:find('\t') ~= nil then
        local tab_size = self.context:tab_size()
        -- Rounds to the next multiple of tab_size
        result = math.ceil(result / tab_size) * tab_size
    end
    return result
end

function Render:render()
    local disabled_language = self.code.disable_background
    if type(disabled_language) == 'table' then
        disabled_language = vim.tbl_contains(disabled_language, self.data.language)
    end
    local background = vim.tbl_contains({ 'normal', 'full' }, self.code.style) and not disabled_language

    local icon = self:language()
    self:border(icon)
    if background then
        self:background(self.node.start_row + 1, self.node.end_row - 2)
    end
    self:left_pad(background)
end

---@private
---@return boolean
function Render:language()
    if not vim.tbl_contains({ 'language', 'full' }, self.code.style) then
        return false
    end

    local node = self.data.language_node
    if node == nil then
        return false
    end

    local icon, icon_highlight = Icons.get(node.text)
    if self.code.highlight_language ~= nil then
        icon_highlight = self.code.highlight_language
    end
    if icon == nil or icon_highlight == nil then
        return false
    end

    if self.code.sign then
        self:sign(icon, icon_highlight)
    end

    local icon_text = icon .. ' '
    local highlight = { icon_highlight }
    if self.code.border ~= 'none' then
        table.insert(highlight, self.code.highlight)
    end

    if self.code.position == 'left' then
        if self.code.language_name and self:hidden(node) then
            -- Code blocks will pick up varying amounts of leading white space depending on the
            -- context they are in. This gets lumped into the delimiter node and as a result,
            -- after concealing, the extmark will be left shifted. Logic below accounts for this.
            local padding = Str.spaces('start', self.node.text) + self.data.language_padding
            icon_text = Str.pad(padding) .. icon_text .. node.text
        end
        return self.marks:add('code_language', node.start_row, node.start_col, {
            virt_text = { { icon_text, highlight } },
            virt_text_pos = 'inline',
        })
    elseif self.code.position == 'right' then
        if self.code.language_name then
            icon_text = icon_text .. node.text
        end
        local win_col = self.data.max_width - self.data.language_padding
        if self.code.width == 'block' then
            win_col = win_col - Str.width(icon_text) + self.data.indent
        end
        return self.marks:add('code_language', node.start_row, 0, {
            virt_text = { { icon_text, highlight } },
            virt_text_win_col = win_col,
        })
    else
        return false
    end
end

---@private
---@param icon boolean
function Render:border(icon)
    if self.code.border == 'none' then
        return
    end

    ---@param row integer
    ---@param border string
    ---@param context_hidden boolean
    local function add_border(row, border, context_hidden)
        local delim_node = self.node:child('fenced_code_block_delimiter', row)
        if self.code.border == 'thin' and context_hidden and self:hidden(delim_node) then
            local width = self.code.width == 'block' and self.data.max_width or vim.o.columns
            self.marks:add('code_border', row, self.data.col, {
                virt_text = { { border:rep(width - self.data.col), colors.bg_to_fg(self.code.highlight) } },
                virt_text_pos = 'overlay',
            })
        else
            self:background(row, row)
        end
    end

    add_border(self.node.start_row, self.code.above, not icon and self:hidden(self.data.code_node))
    add_border(self.node.end_row - 1, self.code.below, true)
end

---@private
---@param node? render.md.Node
---@return boolean
function Render:hidden(node)
    return self.context:width(node) == 0
end

---@private
---@param start_row integer
---@param end_row integer
function Render:background(start_row, end_row)
    local win_col, padding = 0, {}
    if self.code.width == 'block' then
        win_col = self.data.margin + self.data.max_width + self.data.indent
        table.insert(padding, self:padding_text(vim.o.columns * 2))
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
    local fill_text = self:padding_text(self.data.col)
    local margin_text = self:padding_text(margin)
    local padding_text = self:padding_text(padding, background and self.code.highlight or nil)

    local start_row, end_row = self.node.start_row, (self.node.end_row - 1)
    for row = start_row, end_row do
        local virt_text = {}
        if self.data.col > 0 and vim.tbl_contains(self.data.empty_rows, row) then
            table.insert(virt_text, fill_text)
        end
        if margin > 0 then
            table.insert(virt_text, margin_text)
        end
        if padding > 0 and row > start_row and row < end_row then
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
