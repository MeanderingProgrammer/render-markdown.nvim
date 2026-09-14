local M = {}

---Virtual lines on concealed rows are hidden by Neovim.
---Move them above the next visible row while grouping.
---@param visible render.md.Mark[]
---@param line_count integer
---@return render.md.Mark[]
function M.resolve(visible, line_count)
    local marks = {} ---@type render.md.Mark[]
    for _, mark in ipairs(visible) do
        if mark.replace then
            marks[#marks + 1] = mark
        end
    end
    table.sort(marks, function(a, b)
        return a.start_row < b.start_row
    end)
    if #marks == 0 then
        return {}
    end

    local hidden = {} ---@type table<integer, true>
    for _, mark in ipairs(visible) do
        if mark.opts.conceal_lines then
            local end_row = mark.opts.end_row or mark.start_row
            if end_row > mark.start_row and mark.opts.end_col == 0 then
                end_row = end_row - 1
            end
            for row = mark.start_row, end_row do
                hidden[row] = true
            end
        end
    end

    local groups = {} ---@type render.md.Mark[]
    for _, mark in ipairs(marks) do
        local row = mark.start_row + 1
        while row < line_count and hidden[row] do
            row = row + 1
        end
        local group = groups[#groups]
        if not group or group.start_row ~= row then
            group = {
                conceal = true,
                start_row = row,
                start_col = 0,
                opts = {
                    virt_lines = {},
                    virt_lines_above = true,
                    strict = false,
                },
            }
            groups[#groups + 1] = group
        end
        vim.list_extend(group.opts.virt_lines, mark.replace)
    end
    return groups
end

return M
