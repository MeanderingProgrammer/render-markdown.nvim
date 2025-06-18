local Base = require('render-markdown.render.base')
local colors = require('render-markdown.core.colors')
local env = require('render-markdown.lib.env')
local icons = require('render-markdown.lib.icons')
local str = require('render-markdown.lib.str')

---@class render.md.code.Header
---@field delim_width integer
---@field lang_width integer
---@field more_width integer
---@field render_lang_width integer
---@field icon string?
---@field icon_highlight string?

---@class render.md.code.Data
---@field header render.md.code.Header
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
    if self.context:skip(self.config) then
        return false
    end
    if self.config.style == 'none' then
        return false
    end
    -- skip single line code block
    if self.node.end_row - self.node.start_row <= 1 then
        return false
    end

    local widths = self.node:widths()
    local width = vim.fn.max(widths)
    local language = self:offset(self.config.language_pad, width)
    local left = self:offset(self.config.left_pad, width)
    local right = self:offset(self.config.right_pad, width)

    local header = self:parse_header(self.node)
    local header_width = header.render_lang_width + header.more_width + language
    if not self.context.conceal:enabled() then
        header_width = header_width + header.delim_width + header.lang_width
    end
    if self.config.position == 'right' and header.more_width > 0 then
        header_width = header_width + 1 -- Allow for a space between the language and more
    end
    table.remove(widths, 1) -- Remove the raw header width
    width = vim.fn.max(widths)

    local body =
        math.max(header_width, left + width + right, self.config.min_width)

    self.data = {
        header = header,
        language = language,
        padding = left,
        body = body,
        margin = self:offset(self.config.left_margin, body),
    }
    return true
end

---@param node? render.md.Node
---@return render.md.code.Header
function Render:parse_header(node)
    ---@type render.md.code.Header
    local result = {
        delim_width = 0,
        lang_width = 0,
        more_width = 0,
        render_lang_width = 0,
        icon = nil,
        icon_highlight = nil,
    }

    if not node then
        return result
    end

    local delim = node:child('fenced_code_block_delimiter', node.start_row)
    local info = node:child('info_string')
    local language = info and info:child('language')
    local info_width = info and info.end_col - info.start_col or 0

    result.delim_width = delim and delim.end_col or 0

    if not vim.tbl_contains({ 'language', 'full' }, self.config.style) then
        return result
    end
    if not info or not language then
        return result
    end

    result.lang_width = language.end_col - language.start_col
    result.more_width = info_width - result.lang_width
    result.render_lang_width = result.lang_width
    result.icon, result.icon_highlight = icons.get(language.text)

    if self.config.highlight_language then
        result.icon_highlight = self.config.highlight_language
    end
    if not self.config.language_name then
        result.render_lang_width = 0
    end
    if self.config.language_icon then
        if result.icon then
            if result.render_lang_width > 0 then
                result.render_lang_width = result.render_lang_width + 2 -- include space
            else
                result.render_lang_width = 1
            end
        end
    end
    return result
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
    local info = self.node:child('info_string')
    local language = info and info:child('language')
    self.marks:over(true, language, { conceal = '' })

    local start_row = self.node.start_row
    local above = self.node:child('fenced_code_block_delimiter', start_row)
    self.marks:over(true, above, { conceal = '' })

    local end_row = self.node.end_row - 1
    local below = self.node:child('fenced_code_block_delimiter', end_row)
    self.marks:over(true, below, { conceal = '' })

    local icon = self:language(language, above)
    local has_more = info and language and info.end_col > language.end_col
    self:border(above, self.config.above, not icon and not has_more)
    self:border(below, self.config.below, true)

    local background = self:background_enabled(language)
    if background then
        self:background(start_row + 1, end_row - 1, self.config.highlight)
    end
    self:padding(background)
end

---@private
---@param language? render.md.Node
---@param delim? render.md.Node
---@return boolean
function Render:language(language, delim)
    if not vim.tbl_contains({ 'language', 'full' }, self.config.style) then
        return false
    end
    if not language or not delim then
        return false
    end

    local icon = self.data.header.icon
    local icon_highlight = self.data.header.icon_highlight

    self:sign(self.config.sign, icon, icon_highlight)

    local text = ''
    if self.config.language_icon and icon then
        text = text .. icon .. ' '
    end
    if self.config.language_name then
        text = text .. language.text
    end
    if #text == 0 then
        return false
    end

    local highlight = {} ---@type string[]
    local fallback_highlight = self.config.highlight_fallback
    highlight[#highlight + 1] = (icon_highlight or fallback_highlight)
    local border_highlight = self.config.highlight_border
    if border_highlight ~= false then
        highlight[#highlight + 1] = border_highlight
    end

    if self.config.position == 'left' then
        text = str.pad(self.data.language) .. text
        -- code blocks can pick up varying amounts of leading white space
        -- this is lumped into the delimiter node and needs to be handled
        local spaces = str.spaces('start', delim.text)
        local width = self.context:width(delim)
        if self.context.conceal:enabled() then
            width = self.context.conceal:width('')
        end
        text = str.pad(spaces - width) .. text
        return self.marks:start('code_language', language, {
            virt_text = { { text, highlight } },
            virt_text_pos = 'inline',
        })
    else
        local start = self.data.body - self.data.language
        if self.config.width == 'block' then
            start = start - str.width(text)
        end
        return self.marks:add('code_language', language.start_row, 0, {
            virt_text = { { text, highlight } },
            virt_text_win_col = start + self:indent():size(),
        })
    end
end

---@private
---@param node? render.md.Node
---@param icon string
---@param empty boolean
function Render:border(node, icon, empty)
    local kind = self.config.border
    local highlight = self.config.highlight_border
    if not node or kind == 'none' or highlight == false then
        return
    end
    local row = node.start_row
    if kind == 'thick' then
        self:background(row, row, highlight)
        return
    elseif kind == 'hide' then
        self.marks:over(true, node, { conceal_lines = '' })
        return
    end

    -- Now we are dealing with a 'thin' border
    local border_highlight = self.config.highlight_thin_border
            and colors.bg_as_fg(self.config.highlight_thin_border)
        or colors.bg_as_fg(highlight)

    local block = self.config.width == 'block'
    local col = self.node.start_col
    local width = block and self.data.body - col or vim.o.columns

    if not self.context.conceal:enabled() then
        col = col + node.end_col
    end

    if empty then
        self.marks:add('code_border', row, col, {
            virt_text = {
                {
                    icon:rep(width - col),
                    border_highlight,
                },
            },
            virt_text_pos = 'overlay',
        })
        return
    end

    local indent = self:indent():size()
    local header = self.data.header
    local lang_pad = self.config.language_pad
    local border_pad = 1

    -- Render an initial thick border
    self:background(row, row, highlight)

    if self.config.position == 'left' then
        if lang_pad > 0 then
            self.marks:add('code_border', row, 0, {
                virt_text = {
                    {
                        icon:rep(lang_pad - border_pad),
                        border_highlight,
                    },
                },
                virt_text_pos = 'overlay',
                virt_text_win_col = col + indent,
            })
        end

        local border_start_col = col
            + header.more_width
            + header.render_lang_width
            + lang_pad
            + border_pad

        if not self.context.conceal:enabled() then
            border_start_col = border_start_col + header.lang_width
        end

        if border_start_col < width then
            self.marks:add('code_border', row, 0, {
                virt_text = {
                    {
                        icon:rep(width - border_start_col),
                        border_highlight,
                    },
                },
                virt_text_pos = 'overlay',
                virt_text_win_col = border_start_col + indent,
            })
        end
    else
        local has_more = header.more_width > 0
        local border_start_col = col + header.more_width

        if not self.context.conceal:enabled() then
            border_start_col = border_start_col + header.lang_width
        end
        if has_more then
            border_start_col = border_start_col + border_pad
        end

        local border_width = width
            - border_start_col
            - header.render_lang_width
            - lang_pad
            - border_pad

        self.marks:add('code_border', row, 0, {
            virt_text = {
                {
                    icon:rep(border_width),
                    border_highlight,
                },
            },
            virt_text_pos = 'overlay',
            virt_text_win_col = border_start_col + indent,
        })

        if lang_pad > border_pad then
            self.marks:add('code_border', row, 0, {
                virt_text = {
                    {
                        icon:rep(lang_pad - border_pad),
                        border_highlight,
                    },
                },
                virt_text_pos = 'overlay',
                virt_text_win_col = width - lang_pad + border_pad + indent,
            })
        end
    end
end

---@private
---@param language? render.md.Node
---@return boolean
function Render:background_enabled(language)
    if not vim.tbl_contains({ 'normal', 'full' }, self.config.style) then
        return false
    end
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
---@param highlight string
function Render:background(start_row, end_row, highlight)
    local padding = self:line()
    local win_col = 0
    if self.config.width == 'block' then
        padding:pad(vim.o.columns * 2)
        win_col = self.data.margin + self.data.body + self:indent():size()
    end
    for row = start_row, end_row do
        self.marks:add('code_background', row, self.node.start_col, {
            end_row = row + 1,
            hl_group = highlight,
            hl_eol = true,
        })
        if not padding:empty() and win_col > 0 then
            -- overwrite anything beyond width with padding
            self.marks:add('code_background', row, self.node.start_col, {
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
    local empty, widths = {}, col == 0 and {} or self.node:widths()
    for i, width in ipairs(widths) do
        if width == 0 then
            empty[#empty + 1] = (start_row + i - 1)
        end
    end
    if #empty == 0 and self.data.margin <= 0 and self.data.padding <= 0 then
        return
    end

    -- 0    | low    | includes other marks in padding when code block is at edge
    -- 1000 | medium | includes border marks while likely avoiding other plugins
    local priority = col == 0 and 0 or 1000
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
            self.marks:add(false, row, col, {
                priority = priority,
                virt_text = line:get(),
                virt_text_pos = 'inline',
            })
        end
    end
end

return Render
