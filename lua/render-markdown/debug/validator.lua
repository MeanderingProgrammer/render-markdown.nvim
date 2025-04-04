local Iter = require('render-markdown.lib.iter')

---@alias render.md.debug.SpecKind 'type'|'value'

---@class render.md.debug.Spec
---@field kind render.md.debug.SpecKind
---@field message string
---@field validation fun(value: any): boolean, string?

---@class render.md.debug.ValidatorSpec
---@field private validator render.md.debug.Validator
---@field private config? table<string, any>
---@field private nilable boolean
---@field private path string
---@field private specs table<string, render.md.debug.Spec>
local Spec = {}
Spec.__index = Spec

---@param validator render.md.debug.Validator
---@param config? table<string, any>
---@param nilable boolean
---@param path? string
---@param key any
---@return render.md.debug.ValidatorSpec
function Spec.new(validator, config, nilable, path, key)
    local self = setmetatable({}, Spec)
    self.validator = validator
    self.config = config
    self.nilable = nilable
    self.path = path or ''
    if self.config ~= nil and key ~= nil then
        local keys = type(key) == 'table' and key or { key }
        self.config = vim.tbl_get(self.config, unpack(keys))
        self.config = type(self.config) == 'table' and self.config or nil
        self.path = self.path .. '.' .. table.concat(Iter.list.map(keys, tostring), '.')
    end
    self.specs = {}
    return self
end

---@param keys 'ALL'|string|string[]
---@param f fun(spec: render.md.debug.ValidatorSpec)
---@param nilable? boolean
---@return render.md.debug.ValidatorSpec
function Spec:nested(keys, f, nilable)
    if keys == 'ALL' then
        keys = self.config ~= nil and vim.tbl_keys(self.config) or {}
    else
        keys = type(keys) == 'table' and keys or { keys }
    end
    if nilable == nil then
        nilable = self.nilable
    end
    for _, key in ipairs(keys) do
        self:type(key, 'table')
        f(Spec.new(self.validator, self.config, nilable, self.path, key))
    end
    return self
end

---@param keys string|string[]
---@param ts type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:type(keys, ts)
    local types, message = self:handle_types({}, ts)
    return self:add(keys, 'type', message, function(value)
        return vim.tbl_contains(types, type(value))
    end)
end

---@param keys string|string[]
---@param values string[]
---@param ts? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:one_of(keys, values, ts)
    local options = Iter.list.map(values, vim.inspect)
    local types, message = self:handle_types(options, ts)
    return self:add(keys, 'value', message, function(value)
        return vim.tbl_contains(values, value) or vim.tbl_contains(types, type(value))
    end)
end

---@param keys string|string[]
---@param t type
---@param ts? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:list(keys, t, ts)
    local types, message = self:handle_types({ t .. '[]' }, ts)
    return self:add(keys, 'type', message, function(value)
        if vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if type(item) ~= t then
                    return false, string.format('[%d] is %s', i, type(item))
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
---@return render.md.debug.ValidatorSpec
function Spec:nested_list(keys, t, ts)
    local types, message = self:handle_types({ t, t .. '[]', t .. '[][]' }, ts)
    return self:add(keys, 'type', message, function(value)
        if type(value) == t or vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if type(item) == 'table' then
                    for j, nested in ipairs(item) do
                        if type(nested) ~= t then
                            return false, string.format('[%d][%d] is %s', i, j, type(nested))
                        end
                    end
                elseif type(item) ~= t then
                    return false, string.format('[%d] is %s', i, type(item))
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
---@return render.md.debug.ValidatorSpec
function Spec:one_or_list_of(keys, values, ts)
    local options = '(' .. table.concat(Iter.list.map(values, vim.inspect), '|') .. ')'
    local types, message = self:handle_types({ options, options .. '[]' }, ts)
    return self:add(keys, 'type', message, function(value)
        if vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'string' then
            return vim.tbl_contains(values, value)
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if not vim.tbl_contains(values, item) then
                    return false, string.format('[%d] is %s', i, item)
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
    local types = nil
    if ts == nil then
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
---@param kind render.md.debug.SpecKind
---@param message string
---@param validation fun(v: any): boolean, string?
---@return render.md.debug.ValidatorSpec
function Spec:add(keys, kind, message, validation)
    if self.config ~= nil then
        keys = type(keys) == 'table' and keys or { keys }
        for _, key in ipairs(keys) do
            self.specs[key] = { kind = kind, message = message, validation = validation }
        end
    end
    return self
end

function Spec:check()
    if self.config == nil or vim.tbl_count(self.specs) == 0 then
        return
    end
    self.validator:check(self.path, self.config, self.specs)
end

---@class render.md.debug.Validator
---@field private prefix string
---@field private errors string[]
local Validator = {}
Validator.__index = Validator

---@return render.md.debug.Validator
function Validator.new()
    local self = setmetatable({}, Validator)
    self.prefix = 'render-markdown'
    self.errors = {}
    return self
end

Validator.spec = Spec.new

---@param path string
---@param config table<string, any>
---@param specs table<string, render.md.debug.Spec>
function Validator:check(path, config, specs)
    path = self.prefix .. path
    for key, spec in pairs(specs) do
        local value = config[key]
        local ok, info = spec.validation(value)
        if not ok then
            local message = string.format('%s.%s - expected: %s', path, key, spec.message)
            if spec.kind == 'type' then
                message = message .. string.format(', but got: %s', type(value))
            end
            if spec.kind == 'value' then
                message = message .. string.format(', but got: %s', vim.inspect(value))
            end
            if info ~= nil then
                message = message .. string.format(', info: %s', info)
            end
            self.errors[#self.errors + 1] = message
        end
    end
    for key, _ in pairs(config) do
        if specs[key] == nil then
            local message = string.format('%s.%s - invalid key', path, key)
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
