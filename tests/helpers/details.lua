---@class render.md.test.MarkDetails: render.md.test.MarkInfo
local MarkDetails = {}
MarkDetails.__index = MarkDetails

---@param row integer
---@param col integer
---@param details vim.api.keyset.extmark_details
---@return render.md.test.MarkDetails
function MarkDetails.new(row, col, details)
    local self = setmetatable({}, MarkDetails)
    self.row = { row, details.end_row }
    self.col = { col, details.end_col }
    self.hl_eol = details.hl_eol
    self.hl_group = details.hl_group
    if self.hl_group then
        self.hl_group = MarkDetails.simplify(self.hl_group)
    end
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.conceal = details.conceal
    ---@diagnostic disable-next-line: undefined-field
    self.conceal_lines = details.conceal_lines
    self.hl_mode = details.hl_mode
    self.virt_text = details.virt_text
    if self.virt_text then
        for _, text in ipairs(self.virt_text) do
            text[2] = MarkDetails.simplify(text[2])
        end
    end
    self.virt_text_pos = details.virt_text_pos
    self.virt_text_win_col = details.virt_text_win_col
    self.virt_lines = details.virt_lines
    if self.virt_lines then
        for _, line in ipairs(self.virt_lines) do
            for _, text in ipairs(line) do
                text[2] = MarkDetails.simplify(text[2])
            end
        end
    end
    self.virt_lines_above = details.virt_lines_above
    self.sign_text = details.sign_text
    self.sign_hl_group = details.sign_hl_group
    if self.sign_hl_group then
        self.sign_hl_group = MarkDetails.simplify(self.sign_hl_group)
    end
    self.priority = details.priority
    if self.priority == 4096 then
        self.priority = nil
    end
    return self
end

---@param highlight number|render.md.mark.Hl
---@return string
function MarkDetails.simplify(highlight)
    if type(highlight) == 'number' then
        return tostring(highlight)
    end
    if type(highlight) == 'string' then
        highlight = { highlight }
    end
    local result = {} ---@type string[]
    for _, value in ipairs(highlight) do
        value = value:gsub('RenderMarkdown', 'Rm')
        result[#result + 1] = value
    end
    return table.concat(result, ':')
end

---@param a render.md.test.MarkInfo
---@param b render.md.test.MarkInfo
---@return boolean
function MarkDetails.__lt(a, b)
    local as = MarkDetails.priorities(a)
    local bs = MarkDetails.priorities(b)
    assert(#as == #bs, 'priorities must be same length')
    for i = 1, #as do
        if as[i] ~= bs[i] then
            return as[i] < bs[i]
        end
    end
    return false
end

---@private
---@param mark render.md.test.MarkInfo
---@return number[]
function MarkDetails.priorities(mark)
    local virt_row = 0
    if mark.virt_lines then
        virt_row = mark.virt_lines_above and -0.5 or 0.5
    end
    local win_col = mark.virt_text_win_col or 0
    local width = 0
    for _, text in ipairs(mark.virt_text or {}) do
        width = width + #text[1] ---@type number
    end
    for _, line in ipairs(mark.virt_lines or {}) do
        for _, text in ipairs(line) do
            width = width + #text[1] ---@type number
        end
    end
    ---@type number[]
    return {
        -- rows
        mark.row[1] + virt_row,
        (mark.row[2] or mark.row[1]) + virt_row,
        -- cols
        math.max(mark.col[1], win_col),
        math.max((mark.col[2] or mark.col[1]), win_col),
        -- signs
        mark.sign_text and 0 or 1,
        -- inline text
        mark.virt_text_pos == 'inline' and 0 or 1,
        -- text width
        width,
        -- conceal
        mark.conceal and 0 or 1,
        mark.conceal_lines and 0 or 1,
    }
end

return MarkDetails
