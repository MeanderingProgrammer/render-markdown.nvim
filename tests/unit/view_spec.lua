---@module 'luassert'

local View = require('render-markdown.request.view')
local mock = require('luassert.mock')

describe('view', function()
    ---@param ranges table<integer, render.md.Range>
    local function setup(ranges)
        local env = mock(require('render-markdown.lib.env'), true)
        env.buf.wins.on_call_with(0).returns(vim.tbl_keys(ranges))
        for win, range in pairs(ranges) do
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
end)
