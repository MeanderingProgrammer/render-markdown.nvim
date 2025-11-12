---@module 'luassert'

local str = require('render-markdown.lib.str')

describe('str', function()
    describe('sub', function()
        it('single', function()
            local s = 'abc'
            assert.same('a', str.sub(s, 1, 1))
            assert.same('b', str.sub(s, 2, 2))
            assert.same('c', str.sub(s, 3, 3))
            assert.same('ab', str.sub(s, 1, 2))
            assert.same('bc', str.sub(s, 2, 3))
            assert.same(s, str.sub(s, 1, 3))
        end)

        it('double', function()
            local s = 'a🕛b'
            assert.same('a', str.sub(s, 1, 1))
            assert.same('', str.sub(s, 2, 2))
            assert.same('', str.sub(s, 3, 3))
            assert.same('b', str.sub(s, 4, 4))
            assert.same('a', str.sub(s, 1, 2))
            assert.same('🕛', str.sub(s, 2, 3))
            assert.same('b', str.sub(s, 3, 4))
            assert.same('a🕛', str.sub(s, 1, 3))
            assert.same('🕛b', str.sub(s, 2, 4))
            assert.same(s, str.sub(s, 1, 4))
        end)
    end)
end)
