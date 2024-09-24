---@class render.md.debug.ValidatorSpec
---@field private validator render.md.debug.Validator
---@field private nilable? boolean
---@field private suffix string
---@field private input? table<string, any>
---@field private opts table<string, vim.validate.Spec>
local Spec = {}
Spec.__index = Spec

---@param validator render.md.debug.Validator
---@param path string
---@param input table<string, any>
---@param key? string|string[]
---@param nilable? boolean
---@return render.md.debug.ValidatorSpec
function Spec.new(validator, path, input, key, nilable)
    local self = setmetatable({}, Spec)
    self.validator = validator
    self.nilable = nilable
    self.suffix = path
    self.input = input
    self.opts = {}
    if key ~= nil then
        key = type(key) == 'table' and key or { key }
        self.suffix = self.suffix .. '.' .. table.concat(key, '.')
        self.input = vim.tbl_get(self.input, unpack(key))
        assert(self.input ~= nil or self.nilable == true)
    end
    return self
end

---@return string
function Spec:get_suffix()
    return self.suffix
end

---@return table<string, any>
function Spec:get_input()
    return self.input
end

---@param f fun(spec: render.md.debug.ValidatorSpec)
---@param nilable? boolean
function Spec:for_each(f, nilable)
    for name in pairs(self.input or {}) do
        f(Spec.new(self.validator, self.suffix, self.input, name, nilable))
    end
end

---@param keys string|string[]
---@param types type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:type(keys, types)
    return self:add(keys, types, nil)
end

---@param keys string|string[]
---@param values string[]
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:one_of(keys, values, input_types)
    local types, suffix = self:handle_types(input_types)
    return self:add(keys, function(v)
        return vim.tbl_contains(values, v) or vim.tbl_contains(types, type(v))
    end, 'one of ' .. vim.inspect(values) .. suffix)
end

---@param keys string|string[]
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:string_array(keys, input_types)
    local types, suffix = self:handle_types(input_types)
    return self:add(keys, function(v)
        if vim.tbl_contains(types, type(v)) then
            return true
        elseif type(v) == 'table' then
            for i, item in ipairs(v) do
                if type(item) ~= 'string' then
                    return false, string.format('Index %d is %s', i, type(item))
                end
            end
            return true
        else
            return false
        end
    end, 'string array' .. suffix)
end

---@param keys string|string[]
---@param values string[]
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:one_or_array_of(keys, values, input_types)
    local types, suffix = self:handle_types(input_types)
    return self:add(keys, function(v)
        if vim.tbl_contains(types, type(v)) then
            return true
        elseif type(v) == 'string' then
            return vim.tbl_contains(values, v)
        elseif type(v) == 'table' then
            for i, item in ipairs(v) do
                if not vim.tbl_contains(values, item) then
                    return false, string.format('Index %d is %s', i, item)
                end
            end
            return true
        else
            return false
        end
    end, 'one or array of ' .. vim.inspect(values) .. suffix)
end

---@private
---@param input_types? type|type[]
---@return type[], string
function Spec:handle_types(input_types)
    local types = nil
    if input_types == nil then
        types = {}
    elseif type(input_types) == 'string' then
        types = { input_types }
    else
        types = input_types
    end
    if self.nilable then
        table.insert(types, 'nil')
    end
    return types, #types == 0 and '' or (' or type ' .. vim.inspect(types))
end

---@private
---@param keys string|string[]
---@param logic type|type[]|fun(v: any): boolean, any?
---@param message string?
---@return render.md.debug.ValidatorSpec
function Spec:add(keys, logic, message)
    if self.input ~= nil then
        keys = type(keys) == 'table' and keys or { keys }
        for _, key in ipairs(keys) do
            ---@diagnostic disable-next-line: assign-type-mismatch
            self.opts[key] = { self.input[key], logic, message or self.nilable }
        end
    end
    return self
end

function Spec:check()
    if self.input ~= nil then
        self.validator:check(self.suffix, self.input, self.opts)
    end
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

---@param path string
---@param input table<string, any>
---@param key? string|string[]
---@param nilable? boolean
---@return render.md.debug.ValidatorSpec
function Validator:spec(path, input, key, nilable)
    return Spec.new(self, path, input, key, nilable)
end

---@param suffix string
---@param input table<string, any>
---@param opts table<string, vim.validate.Spec>
function Validator:check(suffix, input, opts)
    local path = self.prefix .. suffix
    local ok, err = pcall(vim.validate, opts)
    if not ok then
        table.insert(self.errors, path .. '.' .. err)
    end
    for key, _ in pairs(input) do
        if opts[key] == nil then
            table.insert(self.errors, string.format('%s.%s: is not a valid key', path, key))
        end
    end
end

---@return string[]
function Validator:get_errors()
    return self.errors
end

return Validator
