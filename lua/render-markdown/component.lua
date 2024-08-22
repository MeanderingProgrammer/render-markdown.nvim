local state = require('render-markdown.state')

---@class render.md.ComponentHelper
local M = {}

---@param buf integer
---@param text string
---@param comparison 'exact'|'contains'
---@return render.md.CustomComponent?
function M.callout(buf, text, comparison)
    ---@param callout render.md.CustomComponent
    ---@return boolean
    local function matches(callout)
        if comparison == 'exact' then
            return text:lower() == callout.raw:lower()
        elseif comparison == 'contains' then
            return text:lower():find(callout.raw:lower(), 1, true) ~= nil
        else
            error(string.format('Unhandled comparison: %s', comparison))
        end
    end
    for _, callout in pairs(state.get_config(buf).callout) do
        if matches(callout) then
            return callout
        end
    end
    return nil
end

---@param buf integer
---@param text string
---@param comparison 'exact'|'starts'
---@return render.md.CustomComponent?
function M.checkbox(buf, text, comparison)
    ---@param checkbox render.md.CustomComponent
    ---@return boolean
    local function matches(checkbox)
        if comparison == 'exact' then
            return text == checkbox.raw
        elseif comparison == 'starts' then
            return vim.startswith(text, checkbox.raw)
        else
            error(string.format('Unhandled comparison: %s', comparison))
        end
    end
    for _, checkbox in pairs(state.get_config(buf).checkbox.custom) do
        if matches(checkbox) then
            return checkbox
        end
    end
    return nil
end

return M
