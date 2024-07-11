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

local M = {}

---@param opts? render.md.UserConfig
M.setup_only = function(opts)
    require('render-markdown').setup(opts)
end

---@param file string
---@param opts? render.md.UserConfig
M.setup = function(file, opts)
    M.setup_only(opts)
    vim.cmd('e ' .. file)
    util.scheduler()
end

---@param row integer
---@param level integer
---@return render.md.MarkInfo[]
M.heading = function(row, level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local foreground = string.format('@markup.heading.%d.markdown', level)
    local backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete', 'DiffDelete', 'DiffDelete', 'DiffDelete' }
    return {
        {
            row = { row, row + 1 },
            col = { 0, 0 },
            hl_eol = true,
            hl_group = backgrounds[level],
            virt_text = { { icons[level], { foreground, backgrounds[level] } } },
            virt_text_pos = 'overlay',
        },
        {
            row = { row, row },
            col = { 0, level },
            sign_text = '󰫎 ',
            sign_hl_group = foreground,
        },
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
