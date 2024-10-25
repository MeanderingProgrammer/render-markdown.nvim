---@class render.md.debug.ValidatorSpec
---@field private validator render.md.debug.Validator
---@field private config? table<string, any>
---@field private nilable boolean
---@field private path string
---@field private opts table<string, vim.validate.Spec>
local Spec = {}
Spec.__index = Spec

---@param validator render.md.debug.Validator
---@param config table<string, any>
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
    self.opts = {}
    if key ~= nil then
        key = type(key) == 'table' and key or { key }
        self.path = self.path .. '.' .. table.concat(key, '.')
        self.config = vim.tbl_get(self.config, unpack(key))
        assert(self.config ~= nil or self.nilable)
    end
    return self
end

---@return string
function Spec:get_path()
    return self.path
end

---@return table<string, any>
function Spec:get_config()
    return self.config
end

---@param nilable boolean
---@param f fun(spec: render.md.debug.ValidatorSpec)
function Spec:for_each(nilable, f)
    for name in pairs(self.config or {}) do
        local spec = Spec.new(self.validator, self.config, nilable, name, self.path)
        f(spec)
        spec:check()
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
---@param list_type type
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:list(keys, list_type, input_types)
    local types, suffix = self:handle_types(input_types)
    return self:add(keys, function(v)
        if vim.tbl_contains(types, type(v)) then
            return true
        elseif type(v) == 'table' then
            for i, item in ipairs(v) do
                if type(item) ~= list_type then
                    return false, string.format('[%d] is %s', i, type(item))
                end
            end
            return true
        else
            return false
        end
    end, list_type .. ' list' .. suffix)
end

---@param keys string|string[]
---@param list_type type
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:list_or_list_of_list(keys, list_type, input_types)
    local types, suffix = self:handle_types(input_types)
    return self:add(keys, function(v)
        if vim.tbl_contains(types, type(v)) then
            return true
        elseif type(v) == 'table' then
            for i, item in ipairs(v) do
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
    end, list_type .. ' list or list of list' .. suffix)
end

---@param keys string|string[]
---@param values string[]
---@param input_types? type|type[]
---@return render.md.debug.ValidatorSpec
function Spec:one_or_list_of(keys, values, input_types)
    local types, suffix = self:handle_types(input_types)
    return self:add(keys, function(v)
        if vim.tbl_contains(types, type(v)) then
            return true
        elseif type(v) == 'string' then
            return vim.tbl_contains(values, v)
        elseif type(v) == 'table' then
            for i, item in ipairs(v) do
                if not vim.tbl_contains(values, item) then
                    return false, string.format('[%d] is %s', i, item)
                end
            end
            return true
        else
            return false
        end
    end, 'one or list of ' .. vim.inspect(values) .. suffix)
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
    if self.nilable and not vim.tbl_contains(types, 'nil') then
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
    if self.config ~= nil then
        keys = type(keys) == 'table' and keys or { keys }
        for _, key in ipairs(keys) do
            ---@diagnostic disable-next-line: assign-type-mismatch
            self.opts[key] = { self.config[key], logic, message or self.nilable }
        end
    end
    return self
end

function Spec:check()
    if self.config == nil then
        return
    end
    if vim.tbl_count(self.opts) == 0 then
        return
    end
    self.validator:check(self.path, self.config, self.opts)
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

---@param suffix string
---@param config table<string, any>
---@param opts table<string, vim.validate.Spec>
function Validator:check(suffix, config, opts)
    local path = self.prefix .. suffix
    local ok, err = pcall(vim.validate, opts)
    if not ok then
        table.insert(self.errors, path .. '.' .. err)
    end
    for key, _ in pairs(config) do
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
