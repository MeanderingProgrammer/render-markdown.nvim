---@module 'luassert'

local ui = require('render-markdown.ui')
local eq = assert.are.same

---@class render.md.test.Row
---@field private value integer
local Row = {}
Row.__index = Row

---@return render.md.test.Row
function Row.new()
    local self = setmetatable({}, Row)
    self.value = 0
    return self
end

---@return integer
function Row:get()
    return self.value
end

---@param n? integer
---@return integer
function Row:increment(n)
    self.value = self.value + (n or 1)
    return self.value
end

---@class render.md.MarkInfo
---@field row integer[]
---@field col integer[]
---@field hl_eol? boolean
---@field hl_group? string
---@field conceal? string
---@field virt_text? { [1]: string, [2]: string|string[] }[]
---@field virt_text_pos? string
---@field virt_text_win_col? integer
---@field virt_lines? { [1]: string, [2]: string }[][]
---@field virt_lines_above? boolean
---@field sign_text? string
---@field sign_hl_group? string

---@class render.md.test.Util
local M = {}

---@param file string
---@param opts? render.md.UserConfig
function M.setup(file, opts)
    require('render-markdown').setup(opts)
    vim.cmd('e ' .. file)
    vim.wait(0)
end

---@return render.md.test.Row
function M.row()
    return Row.new()
end

---@param row integer
---@param level integer
---@return render.md.MarkInfo[]
function M.heading(row, level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local foreground = M.hl(string.format('H%d', level))
    local background = M.hl(string.format('H%dBg', level))
    ---@type render.md.MarkInfo
    local sign_mark = {
        row = { row, row },
        col = { 0, level },
        sign_text = '󰫎 ',
        sign_hl_group = M.hl('_' .. foreground .. '_' .. M.hl('Sign')),
    }
    if row == 0 then
        return { sign_mark }
    else
        ---@type render.md.MarkInfo
        local icon_mark = {
            row = { row, row },
            col = { 0, level },
            virt_text = { { icons[level], { foreground, background } } },
            virt_text_pos = 'overlay',
        }
        ---@type render.md.MarkInfo
        local background_mark = {
            row = { row, row + 1 },
            col = { 0, 0 },
            hl_group = background,
            hl_eol = true,
        }
        return { icon_mark, background_mark, sign_mark }
    end
end

---@param row integer
---@param col integer
---@param level integer
---@param spaces? integer
---@return render.md.MarkInfo
function M.bullet(row, col, level, spaces)
    local icons = { '●', '○', '◆', '◇' }
    spaces = spaces or 0
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { col, col + spaces + 2 },
        virt_text = { { string.rep(' ', spaces) .. icons[level], M.hl('Bullet') } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo
function M.inline_code(row, start_col, end_col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        hl_eol = false,
        hl_group = M.hl('CodeInline'),
    }
end

---@param row integer
---@param col integer
---@return render.md.MarkInfo
function M.code_row(row, col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row + 1 },
        col = { col, 0 },
        hl_eol = true,
        hl_group = M.hl('Code'),
    }
end

---@param row integer
---@param col integer
---@param name 'python'|'lua'|'rust'
---@return render.md.MarkInfo[]
function M.code_language(row, col, name)
    local icon, highlight
    if name == 'python' then
        icon, highlight = '󰌠 ', 'MiniIconsYellow'
    elseif name == 'lua' then
        icon, highlight = '󰢱 ', 'MiniIconsAzure'
    elseif name == 'rust' then
        icon, highlight = '󱘗 ', 'MiniIconsOrange'
    end
    ---@type render.md.MarkInfo
    local sign_mark = {
        row = { row, row },
        col = { col + 3, col + 3 + #name },
        sign_text = icon,
        sign_hl_group = M.hl('_' .. highlight .. '_' .. M.hl('Sign')),
    }
    ---@type render.md.MarkInfo
    local language_mark = {
        row = { row },
        col = { col + 3 },
        virt_text = { { icon .. name, { highlight, M.hl('Code') } } },
        virt_text_pos = 'inline',
    }
    return { sign_mark, language_mark }
end

---@param row integer
---@param col integer
---@param width? integer
function M.code_below(row, col, width)
    width = (width or vim.opt.columns:get()) - col
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep('▀', width), M.hl('_Inverse_' .. M.hl('Code')) } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param kind 'image'|'link'|'web'
---@return render.md.MarkInfo
function M.link(row, start_col, end_col, kind)
    local icon
    if kind == 'image' then
        icon = '󰥶 '
    elseif kind == 'link' then
        icon = '󰌹 '
    elseif kind == 'web' then
        icon = '󰖟 '
    end
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { icon, M.hl('Link') } },
        virt_text_pos = 'inline',
    }
end

---@param row integer
---@param format string
---@param highlight string
---@return render.md.MarkInfo
function M.quote(row, format, highlight)
    local quote = string.format(format, '▋')
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { 0, vim.fn.strdisplaywidth(quote) },
        virt_text = { { quote, M.hl(highlight) } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param head boolean
---@return render.md.MarkInfo
function M.table_pipe(row, col, head)
    local highlight = head and 'TableHead' or 'TableRow'
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { col, col + 1 },
        virt_text = { { '│', M.hl(highlight) } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param spaces integer
---@return render.md.MarkInfo
function M.table_padding(row, col, spaces)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep(' ', spaces), M.hl('TableFill') } },
        virt_text_pos = 'inline',
    }
end

---@param row integer
---@param section 'above'|'delimiter'|'below'
---@param lengths integer[]
---@return render.md.MarkInfo
function M.table_border(row, section, lengths)
    local border
    local highlight
    if section == 'above' then
        border = { '┌', '┬', '┐' }
        highlight = 'TableHead'
    elseif section == 'delimiter' then
        border = { '├', '┼', '┤' }
        highlight = 'TableHead'
    elseif section == 'below' then
        border = { '└', '┴', '┘' }
        highlight = 'TableRow'
    end

    local parts = vim.tbl_map(function(length)
        return string.rep('─', length)
    end, lengths)
    local value = border[1] .. table.concat(parts, border[2]) .. border[3]

    if vim.tbl_contains({ 'above', 'below' }, section) then
        ---@type render.md.MarkInfo
        return {
            row = { row },
            col = { 0 },
            virt_lines = { { { value, M.hl(highlight) } } },
            virt_lines_above = section == 'above',
        }
    else
        ---@type render.md.MarkInfo
        return {
            row = { row, row },
            col = { 0, vim.fn.strdisplaywidth(value) },
            virt_text = { { value, M.hl(highlight) } },
            virt_text_pos = 'overlay',
        }
    end
end

---@param suffix string
---@return string
function M.hl(suffix)
    return 'RenderMarkdown' .. suffix
end

---@return render.md.MarkInfo[]
function M.get_actual_marks()
    local actual = {}
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.namespace, 0, -1, { details = true })
    for _, mark in ipairs(marks) do
        local _, row, col, details = unpack(mark)
        ---@type render.md.MarkInfo
        local mark_info = {
            row = { row, details.end_row },
            col = { col, details.end_col },
            hl_eol = details.hl_eol,
            hl_group = details.hl_group,
            conceal = details.conceal,
            virt_text = details.virt_text,
            virt_text_pos = details.virt_text_pos,
            virt_text_win_col = details.virt_text_win_col,
            virt_lines = details.virt_lines,
            virt_lines_above = details.virt_lines_above,
            sign_text = details.sign_text,
            sign_hl_group = details.sign_hl_group,
        }
        table.insert(actual, mark_info)
    end
    return actual
end

---@param expected (render.md.MarkInfo|render.md.MarkInfo[])[]
---@param actual render.md.MarkInfo[]
function M.marks_are_equal(expected, actual)
    expected = vim.iter(expected)
        :map(function(mark_or_marks)
            if vim.islist(mark_or_marks) then
                return mark_or_marks
            else
                return { mark_or_marks }
            end
        end)
        :flatten()
        :totable()

    for i = 1, math.min(#expected, #actual) do
        eq(expected[i], actual[i], string.format('Marks at index %d mismatch', i))
    end
    eq(#expected, #actual, 'Different number of marks found')
end

return M
