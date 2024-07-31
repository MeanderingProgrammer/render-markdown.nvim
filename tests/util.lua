---@module 'luassert'

local ui = require('render-markdown.ui')
local eq = assert.are.same

---@class render.md.MarkInfo
---@field row integer[]
---@field col integer[]
---@field hl_eol? boolean
---@field hl_group? string
---@field conceal? string
---@field virt_text? { [1]: string, [2]: string|string[] }[]
---@field virt_text_pos? string
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
        local background_mark = {
            row = { row, row + 1 },
            col = { 0, 0 },
            hl_group = background,
            hl_eol = true,
        }
        ---@type render.md.MarkInfo
        local icon_mark = {
            row = { row, row },
            col = { 0, level },
            virt_text = { { icons[level], { foreground, background } } },
            virt_text_pos = 'overlay',
        }
        return { background_mark, icon_mark, sign_mark }
    end
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

---@param start_row integer
---@param end_row integer
---@return render.md.MarkInfo
function M.code_block(start_row, end_row)
    ---@type render.md.MarkInfo
    return {
        row = { start_row, end_row },
        col = { 0, 0 },
        hl_eol = true,
        hl_group = M.hl('Code'),
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param icon string
---@param name string
---@param highlight string
---@return render.md.MarkInfo[]
function M.code_language(row, start_col, end_col, icon, name, highlight)
    ---@type render.md.MarkInfo
    local sign_mark = {
        row = { row, row },
        col = { start_col, end_col },
        sign_text = icon,
        sign_hl_group = M.hl('_' .. highlight .. '_' .. M.hl('Sign')),
    }
    ---@type render.md.MarkInfo
    local language_mark = {
        row = { row },
        col = { start_col },
        virt_text = { { icon .. name, { highlight, M.hl('Code') } } },
        virt_text_pos = 'inline',
    }
    return { sign_mark, language_mark }
end

---@param row integer
---@param col integer
function M.code_below(row, col)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep('▀', vim.opt.columns:get()), M.hl('_Inverse_' .. M.hl('Code')) } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param image boolean
---@return render.md.MarkInfo
function M.link(row, start_col, end_col, image)
    local icon
    if image then
        icon = '󰥶 '
    else
        icon = '󰌹 '
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
    local highlight
    if head then
        highlight = 'TableHead'
    else
        highlight = 'TableRow'
    end
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
            virt_lines = details.virt_lines,
            virt_lines_above = details.virt_lines_above,
            sign_text = details.sign_text,
            sign_hl_group = details.sign_hl_group,
        }
        table.insert(actual, mark_info)
    end
    return actual
end

---@param expected render.md.MarkInfo[]
---@param actual render.md.MarkInfo[]
function M.marks_are_equal(expected, actual)
    for i = 1, math.min(#expected, #actual) do
        eq(expected[i], actual[i], string.format('Marks at index %d mismatch', i))
    end
    eq(#expected, #actual, 'Different number of marks found')
end

return M
