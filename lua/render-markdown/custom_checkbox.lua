local state = require('render-markdown.state')

local M = {}

---@param value string
---@return render.md.CustomCheckbox?
M.get_exact = function(value)
    for _, checkbox in pairs(state.config.checkbox.custom) do
        if checkbox.text == value then
            return checkbox
        end
    end
    return nil
end

---@param value string
---@return render.md.CustomCheckbox?
M.get_starts = function(value)
    for _, checkbox in pairs(state.config.checkbox.custom) do
        if vim.startswith(value, checkbox.text) then
            return checkbox
        end
    end
    return nil
end

return M
