local Base = require('render-markdown.render.base')
local Icons = require('render-markdown.lib.icons')
local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.data.Code
---@field col integer
---@field start_row integer
---@field end_row integer
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
    if not self.code.enabled or self.code.style == 'none' then
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
    local language_padding = self.context:resolve_offset(self.code.language_pad, max_width)
    local left_padding = self.context:resolve_offset(self.code.left_pad, max_width)
    local right_padding = self.context:resolve_offset(self.code.right_pad, max_width)
    max_width = math.max(widths[1] + language_padding, left_padding + max_width + right_padding, self.code.min_width)

    self.data = {
        col = self.node.start_col,
        start_row = self.node.start_row,
        end_row = self.node.end_row,
        code_node = code_node,
        language_node = language_node,
        language = (language_node or {}).text,
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
    local highlight = { icon_highlight }
    if add_background then
        table.insert(highlight, self.code.highlight)
    end
    local icon_text = icon .. ' '
    if self.code.position == 'left' then
        if self.code.language_name and self.context:hidden(node) then
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
---@param icon_added boolean
function Render:background(icon_added)
    local width = self.code.width == 'block' and self.data.max_width or self.context:get_width()

    if self.code.border == 'thin' then
        ---@param row integer
        ---@param icon string
        local function add_border(row, icon)
            local virt_text = {}
            if self.data.margin > 0 then
                table.insert(virt_text, { Str.pad(self.data.margin), self.config.padding.highlight })
            end
            table.insert(virt_text, { icon:rep(width - self.data.col), colors.bg_to_fg(self.code.highlight) })
            self.marks:add('code_border', row, self.data.col, {
                virt_text = virt_text,
                virt_text_pos = 'overlay',
            })
        end
        if not icon_added and self.context:hidden(self.data.code_node) and self:delim_hidden(self.data.start_row) then
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
        table.insert(padding, { Str.pad(vim.o.columns * 2), self.config.padding.highlight })
    end
    for row = self.data.start_row, self.data.end_row - 1 do
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
---@param row integer
---@return boolean
function Render:delim_hidden(row)
    return self.context:hidden(self.node:child('fenced_code_block_delimiter', row))
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
    local fill_text = { Str.pad(self.data.col), self.config.padding.highlight }
    local margin_text = { Str.pad(margin), self.config.padding.highlight }
    local background = add_background and self.code.highlight or self.config.padding.highlight
    local padding_text = { Str.pad(padding), background }

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
