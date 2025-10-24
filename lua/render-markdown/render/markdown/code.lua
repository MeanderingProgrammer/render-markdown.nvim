local Base = require('render-markdown.render.base')
local colors = require('render-markdown.core.colors')
local env = require('render-markdown.lib.env')
local icons = require('render-markdown.lib.icons')
local str = require('render-markdown.lib.str')

---@class render.md.code.Data
---@field language integer
---@field padding integer
---@field body integer
---@field margin integer

---@class render.md.render.Code: render.md.Render
---@field private config render.md.code.Config
---@field private data render.md.code.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.code
    if not self.config.enabled then
        return false
    end
    -- skip single line code block
    if self.node:height() <= 2 then
        return false
    end
    local widths = self.node:widths()
    local width = vim.fn.max(widths)

    local language = self:offset(self.config.language_pad, width)
    local left = self:offset(self.config.left_pad, width)
    local right = self:offset(self.config.right_pad, width)

    local body = str.width(self.config.language_left)
        + str.width(self.config.language_right)
        + language
        + widths[1]
    body = math.max(body, left + width + right, self.config.min_width)

    self.data = {
        language = language,
        padding = left,
        body = body,
        margin = self:offset(self.config.left_margin, body),
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
    local result = env.win.percent(self.context.win, value, used)
    if self.node.text:find('\t') then
        -- round to the next multiple of tab
        local tab = env.buf.get(self.context.buf, 'tabstop')
        result = math.ceil(result / tab) * tab
    end
    return result
end

---@protected
function Render:run()
    local start_row = self.node.start_row
    local end_row = self.node.end_row - 1

    local above = self.node:child('fenced_code_block_delimiter', start_row)
    local below = self.node:child('fenced_code_block_delimiter', end_row)
    local info = self.node:child('info_string')

    if self.config.conceal_delimiters then
        self.marks:over(self.config, true, above, { conceal = '' })
        self.marks:over(self.config, true, below, { conceal = '' })
        self.marks:over(self.config, true, info, { conceal = '' })
    end

    local language = info and info:child('language')
    if not self:language(info, language, above) then
        self:border(above, self.config.above)
    end
    self:border(below, self.config.below)

    local background = self:background_enabled(language)
    if background then
        self:background(start_row + 1, end_row - 1)
    end
    self:padding(background)
end

---@private
---@param info? render.md.Node
---@param language? render.md.Node
---@param delim? render.md.Node
---@return boolean
function Render:language(info, language, delim)
    if not self.config.language then
        return false
    end
    if not info or not language or not delim then
        return false
    end

    local icon, icon_hl = icons.get(language.text)
    if self.config.highlight_language then
        icon_hl = self.config.highlight_language
    end
    self:sign(self.config, self.config.sign, icon, icon_hl)

    local language_hl = { icon_hl or self.config.highlight_fallback } ---@type string[]
    local info_hl = { self.config.highlight_info } ---@type string[]
    local border_hl = self.config.highlight_border or nil
    if border_hl then
        language_hl[#language_hl + 1] = border_hl
        info_hl[#info_hl + 1] = border_hl
        border_hl = colors.bg_as_fg(border_hl)
    end

    local text = self:line()
    if self.config.language_icon and icon then
        text:text(icon .. ' ', language_hl)
    end
    if self.config.language_name then
        text:text(language.text, language_hl)
    end
    if self.config.language_info then
        local offset = info.start_col
        text = self:line()
            :text(info.text:sub(1, language.start_col - offset), info_hl)
            :extend(text)
            :text(info.text:sub(language.end_col - offset + 1), info_hl)
    end
    if text:empty() then
        return false
    end

    local body = self:line()
        :text(self.config.language_left, border_hl)
        :extend(text)
        :text(self.config.language_right, border_hl)

    local border = border_hl and self.config.language_border or ' '
    local width = self.data.body - delim.start_col

    local prefix = self:line()
    -- code blocks can pick up varying amounts of leading white space
    -- this is lumped into the delimiter node and needs to be handled
    prefix:rep(border, str.spaces('start', delim.text), border_hl)
    if self.config.position == 'left' then
        prefix:rep(border, self.data.language, border_hl)
        body:rep(border, width - prefix:width() - body:width(), border_hl)
    else
        body:rep(border, self.data.language, border_hl)
        prefix:rep(border, width - prefix:width() - body:width(), border_hl)
    end

    local line = prefix:extend(body)
    if self.config.width == 'full' then
        line:rep(border, vim.o.columns, border_hl)
    end
    return self.marks:start(self.config, 'code_language', delim, {
        virt_text = line:get(),
        virt_text_pos = 'overlay',
    })
end

---@private
---@param node? render.md.Node
---@param thin string
function Render:border(node, thin)
    local kind = self.config.border
    if kind == 'none' or not node then
        return
    end
    if kind == 'hide' then
        self.marks:over(self.config, true, node, { conceal_lines = '' })
        return
    end
    local highlight = self.config.highlight_border or nil
    if not highlight then
        return
    end
    local icon = kind == 'thin' and thin or ' '
    highlight = icon == ' ' and highlight or colors.bg_as_fg(highlight)
    if not highlight then
        return
    end
    local block = self.config.width == 'block'
    local width = block and self.data.body - node.start_col or vim.o.columns
    self.marks:start(self.config, 'code_border', node, {
        virt_text = { { icon:rep(width), highlight } },
        virt_text_pos = 'overlay',
    })
end

---@private
---@param language? render.md.Node
---@return boolean
function Render:background_enabled(language)
    local disable = self.config.disable_background
    if type(disable) == 'boolean' then
        return not disable
    else
        return language == nil or not vim.tbl_contains(disable, language.text)
    end
end

---@private
---@param start_row integer
---@param end_row integer
function Render:background(start_row, end_row)
    local padding = self:line()
    local win_col = 0
    if self.config.width == 'block' then
        padding:pad(vim.o.columns * 2)
        win_col = self.data.margin + self.data.body + self:indent():size()
    end
    local col = self.node.start_col
    for row = start_row, end_row do
        self.marks:add(self.config, 'code_background', row, col, {
            end_row = row + 1,
            hl_group = self.config.highlight,
            hl_eol = true,
        })
        if not padding:empty() and win_col > 0 then
            -- overwrite anything beyond width with padding
            self.marks:add(self.config, 'code_background', row, col, {
                priority = 0,
                virt_text = padding:get(),
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
    local empty = {} ---@type integer[]
    local widths = col == 0 and {} or self.node:widths()
    for i, width in ipairs(widths) do
        if width == 0 then
            empty[#empty + 1] = (start_row + i - 1)
        end
    end
    if #empty == 0 and self.data.margin <= 0 and self.data.padding <= 0 then
        return
    end
    local highlight = background and self.config.highlight or nil
    for row = start_row, end_row do
        local line = self:line()
        if vim.tbl_contains(empty, row) then
            line:pad(col)
        end
        line:pad(self.data.margin)
        if row > start_row and row < end_row then
            line:pad(self.data.padding, highlight)
        end
        if not line:empty() then
            self.marks:add(self.config, false, row, col, {
                priority = 100,
                virt_text = line:get(),
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
