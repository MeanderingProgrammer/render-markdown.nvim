---@alias render.md.debug.Key string|integer

---@class render.md.debug.Diff
local M = {}

---@param t1 table<render.md.debug.Key, any>
---@param t2 table<render.md.debug.Key, any>
---@return table<render.md.debug.Key, any>?
function M.get(t1, t2)
    local keys = vim.tbl_keys(t1)
    for key in pairs(t2) do
        if not vim.tbl_contains(keys, key) then
            keys[#keys + 1] = key
        end
    end
    local result = {}
    for _, key in ipairs(keys) do
        local difference
        local v1, v2 = t1[key], t2[key]
        if type(v1) == 'table' and type(v2) == 'table' then
            difference = M.get(v1, v2)
        elseif v2 == nil then
            difference = vim.NIL
        elseif v1 ~= v2 then
            difference = v2
        end
        result[key] = difference
    end
    return vim.tbl_count(result) > 0 and result or nil
end

return M
