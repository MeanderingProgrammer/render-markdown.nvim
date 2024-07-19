local state = require('render-markdown.state')
local ui = require('render-markdown.ui')
local util = require('plenary.async.util')

local eq = assert.are.same

---@class render.md.MarkInfo
---@field row integer[]
---@field col integer[]
---@field hl_eol? boolean
---@field hl_group? string
---@field conceal? string
---@field virt_text? { [1]: string, [2]: string }[]
---@field virt_text_pos? string
---@field virt_lines? { [1]: string, [2]: string }[][]
---@field virt_lines_above? boolean
---@field sign_text? string
---@field sign_hl_group? string

---@class render.md.TestUtil
local M = {}

---@param opts? render.md.UserConfig
---@return string[]
M.validate = function(opts)
    require('render-markdown').setup(opts)
    return state.validate()
end

---@param file string
---@param opts? render.md.UserConfig
M.setup = function(file, opts)
    require('render-markdown').setup(opts)
    vim.cmd('e ' .. file)
    util.scheduler()
end

---@private
---@type string
M.prefix = 'RenderMarkdown'

---@param row integer
---@param level integer
---@return render.md.MarkInfo[]
M.heading = function(row, level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local foreground = string.format('%sH%d', M.prefix, level)
    local background = string.format('%sH%dBg', M.prefix, level)
    local sign_mark = {
        row = { row, row },
        col = { 0, level },
        sign_text = '󰫎 ',
        sign_hl_group = string.format('%s_%s_%sSign', M.prefix, foreground, M.prefix),
    }
    if row == 0 then
        return { sign_mark }
    else
        return {
            {
                row = { row, row },
                col = { 0, level },
                virt_text = { { icons[level], { foreground, background } } },
                virt_text_pos = 'overlay',
            },
            sign_mark,
            {
                row = { row, row + 1 },
                col = { 0, 0 },
                hl_group = background,
                hl_eol = true,
            },
        }
    end
end

---@param row integer
---@param col integer
---@param level integer
---@param spaces? integer
---@return render.md.MarkInfo
M.bullet = function(row, col, level, spaces)
    local icons = { '●', '○', '◆', '◇' }
    spaces = spaces or 0
    return {
        row = { row, row },
        col = { col, col + spaces + 2 },
        virt_text = { { string.rep(' ', spaces) .. icons[level], M.prefix .. 'Bullet' } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param icon string
---@param highlight string
---@param custom boolean
---@return render.md.MarkInfo[]
M.checkbox = function(row, icon, highlight, custom)
    local virt_text_pos = 'overlay'
    local conceal = nil
    if custom then
        virt_text_pos = 'inline'
        conceal = ''
    end
    return {
        {
            row = { row, row },
            col = { 0, 2 },
            conceal = '',
        },
        {
            row = { row, row },
            col = { 2, 5 },
            virt_text = { { icon, highlight } },
            virt_text_pos = virt_text_pos,
            conceal = conceal,
        },
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo
M.inline_code = function(row, start_col, end_col)
    return {
        row = { row, row },
        col = { start_col, end_col },
        hl_eol = false,
        hl_group = M.prefix .. 'Code',
    }
end

---@param start_row integer
---@param end_row integer
---@return render.md.MarkInfo
M.code_block = function(start_row, end_row)
    return {
        row = { start_row, end_row },
        col = { 0, 0 },
        hl_eol = true,
        hl_group = M.prefix .. 'Code',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param icon string
---@param name string
---@param highlight string
---@return render.md.MarkInfo[]
M.code_language = function(row, start_col, end_col, icon, name, highlight)
    return {
        {
            row = { row, row },
            col = { start_col, end_col },
            sign_text = icon,
            sign_hl_group = string.format('%s_%s_%sSign', M.prefix, highlight, M.prefix),
        },
        {
            row = { row },
            col = { start_col },
            virt_text = { { icon .. name, { highlight, M.prefix .. 'Code' } } },
            virt_text_pos = 'inline',
        },
    }
end

---@param row integer
---@param col integer
M.code_below = function(row, col)
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep('▀', vim.opt.columns:get()), M.prefix .. '_Inverse_' .. M.prefix .. 'Code' } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param image boolean
---@return render.md.MarkInfo
M.link = function(row, start_col, end_col, image)
    local icon = '󰌹 '
    if image then
        icon = '󰥶 '
    end
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { icon, M.prefix .. 'Link' } },
        virt_text_pos = 'inline',
    }
end

---@param row integer
---@param format string
---@param highlight string
---@return render.md.MarkInfo
M.quote = function(row, format, highlight)
    local quote = string.format(format, '▋')
    return {
        row = { row, row },
        col = { 0, vim.fn.strdisplaywidth(quote) },
        virt_text = { { quote, M.prefix .. highlight } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param head boolean
---@return render.md.MarkInfo
M.table_pipe = function(row, col, head)
    local highlight
    if head then
        highlight = 'TableHead'
    else
        highlight = 'TableRow'
    end
    return {
        row = { row, row },
        col = { col, col + 1 },
        virt_text = { { '│', M.prefix .. highlight } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param spaces integer
---@return render.md.MarkInfo
M.table_padding = function(row, col, spaces)
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep(' ', spaces), M.prefix .. 'TableFill' } },
        virt_text_pos = 'inline',
    }
end

---@param row integer
---@param section 'above'|'delimiter'|'below'
---@param lengths integer[]
---@return render.md.MarkInfo
M.table_border = function(row, section, lengths)
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
        return {
            row = { row },
            col = { 0 },
            virt_lines = { { { value, M.prefix .. highlight } } },
            virt_lines_above = section == 'above',
        }
    else
        return {
            row = { row, row },
            col = { 0, vim.fn.strdisplaywidth(value) },
            virt_text = { { value, M.prefix .. highlight } },
            virt_text_pos = 'overlay',
        }
    end
end

---@param row integer
---@param col integer
---@param value string
---@param head boolean
---@return render.md.MarkInfo
M.table_row = function(row, col, value, head)
    local highlight
    if head then
        highlight = 'TableHead'
    else
        highlight = 'TableRow'
    end
    return {
        row = { row, row },
        col = { 0, col },
        virt_text = { { value, M.prefix .. highlight } },
        virt_text_pos = 'overlay',
    }
end

---@return render.md.MarkInfo[]
M.get_actual_marks = function()
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
M.marks_are_equal = function(expected, actual)
    for i = 1, math.min(#expected, #actual) do
        eq(expected[i], actual[i], string.format('Marks at index %d mismatch', i))
    end
    eq(#expected, #actual, 'Different number of marks found')
end

return M
