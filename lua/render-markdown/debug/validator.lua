local Iter = require('render-markdown.lib.iter')

---@enum render.md.debug.spec.Kind
local Kind = {
    data = 'data',
    type = 'type',
}

---@class render.md.debug.Spec
---@field kind render.md.debug.spec.Kind
---@field message string
---@field validation fun(value: any): boolean, string?

---@class render.md.debug.ValidatorSpec
---@field private validator render.md.debug.Validator
---@field private config? table<string, any>
---@field private nilable boolean
---@field private path string[]
---@field private specs table<string, render.md.debug.Spec>
local Spec = {}
Spec.__index = Spec

---@param validator render.md.debug.Validator
---@param config? table<string, any>
---@param nilable boolean
---@param path? string[]
---@param key any
---@return render.md.debug.ValidatorSpec
function Spec.new(validator, config, nilable, path, key)
    local self = setmetatable({}, Spec)
    self.validator = validator
    self.config = config
    self.nilable = nilable
    self.path = vim.list_extend({}, path or {})
    if self.config and key then
        self.config = self.config[key]
        self.config = type(self.config) == 'table' and self.config or nil
        self.path[#self.path + 1] = tostring(key)
    end
    self.specs = {}
    return self
end

---@param f fun(spec: render.md.debug.ValidatorSpec)
---@param nilable? boolean
function Spec:each(f, nilable)
    local keys = self.config and vim.tbl_keys(self.config) or {}
    self:nested(keys, f, nilable)
end

---@param keys string|string[]
---@param f fun(spec: render.md.debug.ValidatorSpec)
---@param nilable? boolean
function Spec:nested(keys, f, nilable)
    keys = type(keys) == 'table' and keys or { keys }
    if nilable == nil then
        nilable = self.nilable
    end
    for _, key in ipairs(keys) do
        self:type(key, 'table')
        f(Spec.new(self.validator, self.config, nilable, self.path, key))
    end
end

---@param keys string|string[]
---@param ts type|type[]
function Spec:type(keys, ts)
    local types, message = self:handle_types({}, ts)
    self:add(keys, Kind.type, message, function(value)
        return vim.tbl_contains(types, type(value))
    end)
end

---@param keys string|string[]
---@param values string[]
---@param ts? type|type[]
function Spec:one_of(keys, values, ts)
    local options = Iter.list.map(values, vim.inspect)
    local types, message = self:handle_types(options, ts)
    self:add(keys, Kind.data, message, function(value)
        local valid_value = vim.tbl_contains(values, value)
        local valid_type = vim.tbl_contains(types, type(value))
        return valid_value or valid_type
    end)
end

---@param keys string|string[]
---@param t type
---@param ts? type|type[]
function Spec:list(keys, t, ts)
    local types, message = self:handle_types({ t .. '[]' }, ts)
    self:add(keys, Kind.type, message, function(value)
        if vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if type(item) ~= t then
                    return false, ('[%d] is %s'):format(i, type(item))
                end
            end
            return true
        else
            return false
        end
    end)
end

---@param keys string|string[]
---@param t type
---@param ts? type|type[]
function Spec:nested_list(keys, t, ts)
    local types, message = self:handle_types({ t, t .. '[]', t .. '[][]' }, ts)
    self:add(keys, Kind.type, message, function(value)
        if type(value) == t or vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if type(item) == 'table' then
                    for j, nested in ipairs(item) do
                        if type(nested) ~= t then
                            local info = ('[%d][%d] is %s'):format(
                                i,
                                j,
                                type(nested)
                            )
                            return false, info
                        end
                    end
                elseif type(item) ~= t then
                    return false, ('[%d] is %s'):format(i, type(item))
                end
            end
            return true
        else
            return false
        end
    end)
end

---@param keys string|string[]
---@param values string[]
---@param ts? type|type[]
function Spec:one_or_list_of(keys, values, ts)
    local body = table.concat(Iter.list.map(values, vim.inspect), '|')
    local options = '(' .. body .. ')'
    local types, message = self:handle_types({ options, options .. '[]' }, ts)
    self:add(keys, Kind.type, message, function(value)
        if vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'string' then
            return vim.tbl_contains(values, value)
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if not vim.tbl_contains(values, item) then
                    return false, ('[%d] is %s'):format(i, item)
                end
            end
            return true
        else
            return false
        end
    end)
end

---@private
---@param custom string[]
---@param ts? type|type[]
---@return type[], string
function Spec:handle_types(custom, ts)
    local types
    if not ts then
        types = {}
    elseif type(ts) == 'string' then
        types = { ts }
    else
        types = ts
    end
    if self.nilable and not vim.tbl_contains(types, 'nil') then
        types[#types + 1] = 'nil'
    end
    return types, table.concat(vim.list_extend(custom, types), ' or ')
end

---@private
---@param keys string|string[]
---@param kind render.md.debug.spec.Kind
---@param message string
---@param validation fun(v: any): boolean, string?
function Spec:add(keys, kind, message, validation)
    if self.config then
        keys = type(keys) == 'table' and keys or { keys }
        for _, key in ipairs(keys) do
            self.specs[key] = {
                kind = kind,
                message = message,
                validation = validation,
            }
        end
    end
end

function Spec:check()
    if not self.config or vim.tbl_count(self.specs) == 0 then
        return
    end
    self.validator:check(self.path, self.config, self.specs)
end

---@class render.md.debug.Validator
---@field private errors string[]
local Validator = {}
Validator.__index = Validator

---@return render.md.debug.Validator
function Validator.new()
    local self = setmetatable({}, Validator)
    self.errors = {}
    return self
end

Validator.spec = Spec.new

---@param path string[]
---@param config table<string, any>
---@param specs table<string, render.md.debug.Spec>
function Validator:check(path, config, specs)
    for key, spec in pairs(specs) do
        local root = vim.list_extend({}, path)
        root[#root + 1] = tostring(key)
        local value = config[key]
        local ok, info = spec.validation(value)
        if not ok then
            local actual
            if spec.kind == Kind.data then
                actual = vim.inspect(value)
            elseif spec.kind == Kind.type then
                actual = type(value)
            else
                error('invalid kind: ' .. spec.kind)
            end
            local body = ('expected: %s, got: %s'):format(spec.message, actual)
            local message = ('%s - %s'):format(table.concat(root, '.'), body)
            if info then
                message = message .. (', info: %s'):format(info)
            end
            self.errors[#self.errors + 1] = message
        end
    end
    for key in pairs(config) do
        local root = vim.list_extend({}, path)
        root[#root + 1] = tostring(key)
        if not specs[key] then
            local message = ('%s - invalid key'):format(table.concat(root, '.'))
            self.errors[#self.errors + 1] = message
        end
    end
end

---@return string[]
function Validator:get_errors()
    table.sort(self.errors)
    return self.errors
end

return Validator
