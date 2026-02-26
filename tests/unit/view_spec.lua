---@module 'luassert'

local View = require('render-markdown.request.view')
local mock = require('luassert.mock')

describe('view', function()
    ---@param ranges table<integer, render.md.Range>
    local function setup(ranges)
        local env = mock(require('render-markdown.lib.env'), true)
        env.buf.wins.on_call_with(0).returns(vim.tbl_keys(ranges))
        for win, range in pairs(ranges) do
            env.valid.on_call_with(0, win).returns(true)
            env.range.on_call_with(0, win, 10).returns(range)
        end
    end

    it('string', function()
        setup({
            [1000] = { 0, 10 },
            [1001] = { 5, 15 },
            [1002] = { 20, 30 },
            [1003] = { 35, 45 },
        })
        assert.same('[0->15,20->30,35->45]', tostring(View.new(0)))
    end)

    it('contains invalid window', function()
        local env = mock(require('render-markdown.lib.env'), true)
        env.buf.wins.on_call_with(0).returns({ 1000 })
        env.valid.on_call_with(0, 1000).returns(true)
        env.range.on_call_with(0, 1000, 10).returns({ 5, 10 })
        env.valid.on_call_with(0, 1001).returns(false)
        assert.is_false(View.new(0):contains(1001))
    end)
end)
