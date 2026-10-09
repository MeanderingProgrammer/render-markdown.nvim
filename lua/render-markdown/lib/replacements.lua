local M = {}

---A wrapped row conceals its source line, which leaves `j`/`k` with no screen
---cell. Draw that row in place: hide the source text, overlay the first
---rendered line, and put the remaining fragments underneath it.
---@param mark render.md.Mark
---@return render.md.mark.Opts
function M.cursor_opts(mark)
    local lines = mark.replace or {}
    local opts = {
        end_row = mark.opts.end_row,
        end_col = mark.opts.end_col,
        conceal = '',
        virt_text = lines[1] or {},
        virt_text_pos = 'overlay',
        strict = false,
    }
    if #lines > 1 then
        local rest = {} ---@type render.md.mark.Line[]
        for i = 2, #lines do
            rest[#rest + 1] = lines[i]
        end
        opts.virt_lines = rest
        opts.virt_lines_above = false
    end
    return opts
end

---Wrapped rows are drawn on their own line. Grouping them above the next
---visible row conceals the source line, and `k` then draws the cursor on the
---table head until that row is given a height.
---@param _visible render.md.Mark[]
---@param _line_count integer
---@param _cursor_row? integer
---@return render.md.Mark[]
function M.resolve(_visible, _line_count, _cursor_row)
    return {}
end

return M
