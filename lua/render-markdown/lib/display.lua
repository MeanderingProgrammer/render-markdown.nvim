---@class render.md.Display
local M = {}

---@param context render.md.request.Context
---@param marks render.md.Mark[]
---@param node render.md.Node
---@return render.md.mark.Line
function M.prefix(context, marks, node)
    local _, source = node:line('first', 0)
    source = source and source:sub(1, node.start_col) or ''

    local overlays = {} ---@type render.md.Mark[]
    for _, mark in ipairs(marks) do
        local opts = mark.opts
        if
            mark.start_row == node.start_row
            and mark.start_col < #source
            and opts.end_col
            and opts.end_col <= #source
            and opts.virt_text
            and opts.virt_text_pos == 'overlay'
        then
            overlays[#overlays + 1] = mark
        end
    end
    table.sort(overlays, function(a, b)
        return a.start_col < b.start_col
    end)

    local line, col = context.config:line(), 0
    for _, mark in ipairs(overlays) do
        if mark.start_col >= col then
            line:text(source:sub(col + 1, mark.start_col))
                :extend(mark.opts.virt_text)
            col = mark.opts.end_col
        end
    end
    return line:text(source:sub(col + 1)):get()
end

---@param context render.md.request.Context
---@param body render.md.node.Body
---@return render.md.mark.Line
function M.line(context, body)
    ---@type table<integer, true>
    local boundaries = {
        [body.start_col] = true,
        [body.end_col] = true,
    }
    ---@param col integer
    local function boundary(col)
        if col > body.start_col and col < body.end_col then
            boundaries[col] = true
        end
    end

    local inline = context.inline:get(body, true)
    local highlights = context.highlights:line(body.start_row)

    for _, value in ipairs(inline) do
        boundary(value.col)
    end
    for _, range in ipairs(highlights.groups) do
        boundary(range[1])
        boundary(range[2])
    end
    for _, range in ipairs(highlights.conceals) do
        boundary(range[1])
        boundary(range[2])
    end

    local columns = vim.tbl_keys(boundaries)
    table.sort(columns)

    local line = context.config:line()
    for i = 1, #columns - 1 do
        local col, stop = columns[i], columns[i + 1]
        for _, value in ipairs(inline) do
            if value.col == col then
                line:extend(value.line)
            end
        end
        local groups = { context.config.padding.highlight } ---@type render.md.mark.Hl[]
        for _, range in ipairs(highlights.groups) do
            if col >= range[1] and col < range[2] then
                local group = range.highlight
                if type(group) == 'table' then
                    vim.list_extend(groups, group)
                else
                    groups[#groups + 1] = group
                end
            end
        end
        local hidden = false
        for _, range in ipairs(highlights.conceals) do
            if col >= range[1] and col < range[2] then
                hidden = true
                if col == math.max(range[1], body.start_col) then
                    line:text(
                        context.conceal:replacement(range.replacement),
                        groups
                    )
                end
                break
            end
        end
        if not hidden then
            line:text(
                body.text:sub(col - body.start_col + 1, stop - body.start_col),
                groups
            )
        end
    end
    for _, value in ipairs(inline) do
        if value.col == body.end_col then
            line:extend(value.line)
        end
    end
    return line:get()
end

return M
