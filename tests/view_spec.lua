---@module 'luassert'

local View = require('render-markdown.request.view')
local mock = require('luassert.mock')

---@param win_ranges table<integer, render.md.Range>
local function env_mock(win_ranges)
    local env = mock(require('render-markdown.lib.env'), true)
    env.buf.windows.on_call_with(0).returns(vim.tbl_keys(win_ranges))
    for win, range in pairs(win_ranges) do
        env.range.on_call_with(0, win, 10).returns(range)
    end
end

describe('view', function()
    it('string', function()
        env_mock({
            [1000] = { 0, 10 },
            [1001] = { 5, 15 },
            [1002] = { 20, 30 },
            [1003] = { 35, 45 },
        })
        assert.same('[0->15,20->30,35->45]', tostring(View.new(0)))
    end)
end)
