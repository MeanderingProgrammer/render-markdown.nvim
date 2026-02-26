---@module 'luassert'

local Base = require('render-markdown.render.base')
local mock = require('luassert.mock')

describe('base', function()
    it('normalizes raw nodes before setup', function()
        local Node = mock(require('render-markdown.lib.node'), true)
        local wrapped = {
            height = function()
                return 3
            end,
        }
        Node.new.on_call_with(1, 'raw-node').returns(wrapped)

        local ran = false
        local Render = setmetatable({}, Base)
        Render.__index = Render

        function Render:setup()
            return type(self.node.height) == 'function'
        end

        function Render:run()
            ran = true
        end

        local ok = Render:execute({ buf = 1 }, {}, 'raw-node')
        assert.is_true(ok)
        assert.is_true(ran)
    end)
end)
