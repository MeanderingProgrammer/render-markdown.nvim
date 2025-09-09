---@class render.md.schema.Context
---@field path string[]
---@field optional boolean
---@field errors string[]
local Context = {}
Context.__index = Context

---@param path string[]
---@param errors string[]
---@return render.md.schema.Context
function Context.new(path, errors)
    local self = setmetatable({}, Context)
    self.path = path
    self.optional = path[1] == 'overrides'
    self.errors = errors
    return self
end

---@param key any
---@return render.md.schema.Context
function Context:get(key)
    local path = vim.deepcopy(self.path)
    path[#path + 1] = tostring(key)
    return Context.new(path, self.errors)
end

---@param expected string
---@param actual string
function Context:error(expected, actual)
    local path = table.concat(self.path, '.')
    local body = ('expected: %s, got: %s'):format(expected, actual)
    self.errors[#self.errors + 1] = ('%s - %s'):format(path, body)
end

---@class render.md.Schema
---@field optional? boolean
---@field enum? table<any, any>
---@field list? render.md.Schema
---@field map? render.md.schema.Map
---@field record? render.md.schema.Record
---@field type? type
---@field union? render.md.Schema[]

---@class render.md.schema.Map
---@field [1] render.md.Schema
---@field [2] render.md.Schema

---@alias render.md.schema.Record table<string, render.md.Schema>

---@class render.md.schema.Validator
local M = {}

---@param data any
---@param schema render.md.Schema
---@return string[]
function M.validate(data, schema)
    local ctx = Context.new({}, {})
    M.check(ctx, data, schema)
    table.sort(ctx.errors)
    return ctx.errors
end

---@private
---@param ctx render.md.schema.Context
---@param data any
---@param schema render.md.Schema
function M.check(ctx, data, schema)
    schema.optional = schema.optional or ctx.optional
    if schema.optional and data == nil then
        -- valid
    elseif schema.enum then
        if not vim.tbl_contains(vim.tbl_values(schema.enum), data) then
            ctx:error(M.type(schema), vim.inspect(data))
        end
    elseif schema.list then
        if type(data) ~= 'table' then
            ctx:error(M.type(schema), type(data))
        else
            ---@cast data table<any, any>
            for key, value in pairs(data) do
                if type(key) ~= 'number' then
                    ctx:get(key):error('nil', type(value))
                else
                    M.check(ctx:get(key), value, schema.list)
                end
            end
        end
    elseif schema.map then
        if type(data) ~= 'table' then
            ctx:error(M.type(schema), type(data))
        else
            ---@cast data table<any, any>
            for key, value in pairs(data) do
                if #M.validate(key, schema.map[1]) > 0 then
                    ctx:get(key):error('nil', type(value))
                else
                    M.check(ctx:get(key), value, schema.map[2])
                end
            end
        end
    elseif schema.record then
        if type(data) ~= 'table' then
            ctx:error(M.type(schema), type(data))
        else
            ---@cast data table<any, any>
            for key, field in pairs(schema.record) do
                M.check(ctx:get(key), data[key], field)
            end
            for key, value in pairs(data) do
                if not schema.record[key] then
                    ctx:get(key):error('nil', type(value))
                end
            end
        end
    elseif schema.type then
        if type(data) ~= schema.type then
            ctx:error(M.type(schema), type(data))
        end
    elseif schema.union then
        local valid = false
        for _, field in ipairs(schema.union) do
            if not valid then
                valid = #M.validate(data, field) == 0
            end
        end
        if not valid then
            ctx:error(M.type(schema), vim.inspect(data))
        end
    else
        error('invalid schema')
    end
end

---@private
---@param schema render.md.Schema
---@return string
function M.type(schema)
    local result ---@type string
    if schema.enum then
        local values = {} ---@type string[]
        for _, value in pairs(schema.enum) do
            values[#values + 1] = vim.inspect(value)
        end
        table.sort(values)
        result = table.concat(values, '|')
    elseif schema.list then
        result = ('%s[]'):format(M.type(schema.list))
    elseif schema.map then
        result = ('map<%s, %s>'):format(
            M.type(schema.map[1]),
            M.type(schema.map[2])
        )
    elseif schema.record then
        result = 'table'
    elseif schema.type then
        result = schema.type
    elseif schema.union then
        local values = {} ---@type string[]
        for _, field in ipairs(schema.union) do
            values[#values + 1] = M.type(field)
        end
        result = table.concat(values, '|')
    end
    assert(result, 'invalid schema')
    if schema.optional then
        result = ('%s?'):format(result)
    end
    return result
end

return M
