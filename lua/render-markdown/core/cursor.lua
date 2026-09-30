local compat = require('render-markdown.lib.compat')
local env = require('render-markdown.lib.env')

---@class render.md.Cursor
local M = {}

---@private
---@type table<integer, integer>
M.rows = {}

---move the cursor off a row that stays hidden under it, in the direction it
---was moving, falling back to the other direction at the buffer edges
---@param buf integer
---@param win integer
function M.update(buf, win)
    -- rows can only be hidden with conceal_lines, events can also be
    -- forwarded to a buffer that is not in the current window (preview)
    if not compat.has_11 or win ~= env.win.current() then
        return
    end
    local row = vim.api.nvim_win_get_cursor(win)[1] - 1
    local prev = M.rows[win] or row
    if not M.visible(win, row) then
        local step = row < prev and -1 or 1
        local target = M.find(buf, win, row, step)
            or M.find(buf, win, row, -step)
        if target then
            M.move(win, target)
            row = target
        end
    end
    M.rows[win] = row
end

---@private
---@param buf integer
---@param win integer
---@param row integer
---@param step integer
---@return integer?
function M.find(buf, win, row, step)
    local rows = vim.api.nvim_buf_line_count(buf)
    row = row + step
    while row >= 0 and row < rows do
        local target = M.visible(win, row)
        if target then
            return target
        end
        row = row + step
    end
    return nil
end

---row to land on if any of row is drawn, the first row of a closed fold
---like j / k do
---@private
---@param win integer
---@param row integer
---@return integer?
function M.visible(win, row)
    local fold = vim.fn.foldclosed(row + 1)
    if fold ~= -1 then
        return fold - 1
    end
    local height = vim.api.nvim_win_text_height(win, {
        start_row = row,
        end_row = row,
    })
    return height.all - height.fill > 0 and row or nil
end

---keep the preferred column, same as a vertical motion would
---@private
---@param win integer
---@param row integer
function M.move(win, row)
    local want = vim.fn.winsaveview().curswant
    local vcol = math.min(want + 1, vim.v.maxcol)
    local col = math.max(vim.fn.virtcol2col(win, row + 1, vcol) - 1, 0)
    vim.fn.winrestview({ lnum = row + 1, col = col, curswant = want })
end

return M
