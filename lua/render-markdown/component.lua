---@class render.md.Component
---@field text string
---@field highlight string

---@class render.md.ComponentHelper
local M = {}

---@param config render.md.BufferConfig
---@param text string
---@param comparison 'exact'|'contains'
---@return render.md.Component?
function M.callout(config, text, comparison)
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
    for _, callout in pairs(config.callout) do
        if matches(callout) then
            return { text = callout.rendered, highlight = callout.highlight }
        end
    end
    return nil
end

---@param config render.md.BufferConfig
---@param text string
---@param comparison 'exact'|'starts'
---@return render.md.Component?
function M.checkbox(config, text, comparison)
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
    for _, checkbox in pairs(config.checkbox.custom) do
        if matches(checkbox) then
            return { text = checkbox.rendered, highlight = checkbox.highlight }
        end
    end
    return nil
end

return M
