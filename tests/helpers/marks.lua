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

---@param mark render.md.test.MarkInfo
function Marks:add(mark)
    table.insert(self.marks, mark)
end

---@param marks render.md.test.MarkInfo[]
function Marks:extend(marks)
    vim.list_extend(self.marks, marks)
end

return Marks
