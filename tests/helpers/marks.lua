---@class render.md.test.Marks
---@field private marks render.md.test.MarkInfo[]
local Marks = {}
Marks.__index = Marks

---@return render.md.test.Marks
function Marks.new()
    local self = setmetatable({}, Marks)
    self.marks = {}
    return self
end

---@return render.md.test.MarkInfo[]
function Marks:get()
    return self.marks
end

---@param start_row integer
---@param end_row? integer
---@param start_col integer
---@param end_col? integer
---@param opts vim.api.keyset.set_extmark
---@return render.md.test.Marks
function Marks:add(start_row, end_row, start_col, end_col, opts)
    ---@type render.md.test.MarkInfo
    ---@diagnostic disable-next-line: assign-type-mismatch
    local mark = opts
    mark.row = { start_row, end_row }
    mark.col = { start_col, end_col }
    table.insert(self.marks, opts)
    return self
end

return Marks
