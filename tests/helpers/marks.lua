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

---@param row render.md.test.Range
---@param col render.md.test.Range
---@param opts vim.api.keyset.set_extmark
function Marks:add(row, col, opts)
    ---@type render.md.test.MarkInfo
    ---@diagnostic disable-next-line: assign-type-mismatch
    local mark = opts
    mark.row = row
    mark.col = col
    self.marks[#self.marks + 1] = mark
end

return Marks
