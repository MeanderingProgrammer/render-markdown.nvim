---@alias render.md.debug.Key string|integer

---@class render.md.debug.Diff
local M = {}

---@param t1 table<render.md.debug.Key, any>
---@param t2 table<render.md.debug.Key, any>
---@return table<render.md.debug.Key, any>
function M.get(t1, t2)
    local result, keys = {}, {}
    M.append_keys(keys, t1)
    M.append_keys(keys, t2)
    for _, key in ipairs(keys) do
        local v1, v2 = t1[key], t2[key]
        if type(v1) == 'table' and type(v2) == 'table' then
            local nested = M.get(v1, v2)
            if vim.tbl_count(nested) > 0 then
                result[key] = nested
            end
        elseif v1 ~= v2 then
            result[key] = v2
        end
    end
    return result
end

---@private
---@param keys render.md.debug.Key[]
---@param t table<render.md.debug.Key, any>
function M.append_keys(keys, t)
    for key in pairs(t) do
        if not vim.tbl_contains(keys, key) then
            keys[#keys + 1] = key
        end
    end
end

return M
