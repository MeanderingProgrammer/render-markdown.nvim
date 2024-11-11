---@class render.md.debug.Spec
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
---@param key? string|string[]
---@param path? string
---@return render.md.debug.ValidatorSpec
function Spec.new(validator, config, nilable, key, path)
    local self = setmetatable({}, Spec)
    self.validator = validator
    self.config = config
    self.nilable = nilable
    self.path = path or ''
    self.specs = {}
    if self.config ~= nil and key ~= nil then
        key = type(key) == 'table' and key or { key }
        self.path = self.path .. '.' .. table.concat(key, '.')
        self.config = vim.tbl_get(self.config, unpack(key))
        self.config = type(self.config) == 'table' and self.config or nil
    end
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
        f(Spec.new(self.validator, self.config, nilable, key, self.path))
    end
    return self
end

---@param keys string|string[]
---@param input_types type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:type(keys, input_types)
    local types, message = self:handle_types(input_types, '')
    return self:add(keys, message, function(value)
        return vim.tbl_contains(types, type(value))
    end)
end

---@param keys string|string[]
---@param values string[]
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:one_of(keys, values, input_types)
    local types, message = self:handle_types(input_types, 'one of ' .. vim.inspect(values))
    return self:add(keys, message, function(value)
        return vim.tbl_contains(values, value) or vim.tbl_contains(types, type(value))
    end)
end

---@param keys string|string[]
---@param list_type type
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:list(keys, list_type, input_types)
    local types, message = self:handle_types(input_types, list_type .. ' list')
    return self:add(keys, message, function(value)
        if vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if type(item) ~= list_type then
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
---@param list_type type
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:list_or_list_of_list(keys, list_type, input_types)
    local types, message = self:handle_types(input_types, list_type .. ' list or list of list')
    return self:add(keys, message, function(value)
        if vim.tbl_contains(types, type(value)) then
            return true
        elseif type(value) == 'table' then
            for i, item in ipairs(value) do
                if type(item) == 'table' then
                    for j, nested in ipairs(item) do
                        if type(nested) ~= list_type then
                            return false, string.format('[%d][%d] is %s', i, j, type(nested))
                        end
                    end
                elseif type(item) ~= list_type then
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
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:one_or_list_of(keys, values, input_types)
    local types, message = self:handle_types(input_types, 'one or list of ' .. vim.inspect(values))
    return self:add(keys, message, function(value)
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
---@param input_types? type|type[]
---@param prefix string
---@return type[], string
function Spec:handle_types(input_types, prefix)
    local types = nil
    if input_types == nil then
        types = {}
    elseif type(input_types) == 'string' then
        types = { input_types }
    else
        types = input_types
    end
    if self.nilable and not vim.tbl_contains(types, 'nil') then
        table.insert(types, 'nil')
    end
    local message = prefix
    if #types > 0 then
        if #message > 0 then
            message = message .. ' or '
        end
        message = message .. 'type ' .. table.concat(types, ' or ')
    end
    return types, message
end

---@private
---@param keys string|string[]
---@param message string
---@param validation fun(v: any): boolean, string?
---@return render.md.debug.ValidatorSpec
function Spec:add(keys, message, validation)
    if self.config ~= nil then
        keys = type(keys) == 'table' and keys or { keys }
        for _, key in ipairs(keys) do
            self.specs[key] = { message = message, validation = validation }
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
            local message = string.format('%s.%s: expected %s, got %s', path, key, spec.message, type(value))
            if info ~= nil then
                message = message .. string.format(', info: %s', info)
            end
            table.insert(self.errors, message)
        end
    end
    for key, _ in pairs(config) do
        if specs[key] == nil then
            local message = string.format('%s.%s: is not a valid key', path, key)
            table.insert(self.errors, message)
        end
    end
end

---@return string[]
function Validator:get_errors()
    table.sort(self.errors)
    return self.errors
end

return Validator
