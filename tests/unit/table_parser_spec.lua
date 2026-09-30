---@module 'luassert'

local Node = require('render-markdown.lib.node')
local Parser = require('render-markdown.parser.table')
local View = require('render-markdown.request.view')
local spy = require('luassert.spy')
local str = require('render-markdown.lib.str')
local stub = require('luassert.stub')

describe('table parser', function()
    describe('early row filtering', function()
        local buf, wrapped, cols, row

        before_each(function()
            buf = vim.api.nvim_create_buf(false, true)
            local lines = { '| A | B |', '| - | - |' }
            for i = 1, 20 do
                lines[#lines + 1] = '| row ' .. i .. ' | value |'
            end
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            cols = stub(Parser, 'cols', function()
                return { { width = 1, alignment = Parser.Alignment.default } }
            end)
            row = stub(Parser, 'row', function(_, node)
                return { node = node, pipes = {}, cells = {} }
            end)
        end)

        after_each(function()
            if wrapped then
                wrapped:revert()
                wrapped = nil
            end
            cols:revert()
            row:revert()
            vim.api.nvim_buf_delete(buf, { force = true })
        end)

        local function parse(ranges)
            local tree = vim.treesitter.get_parser(buf, 'markdown'):parse()[1]
            local query =
                vim.treesitter.query.parse('markdown', '(pipe_table) @table')
            local _, ts_root = query:iter_captures(tree:root(), buf)()
            assert.is_not_nil(ts_root)
            local root = Node.new(buf, ts_root)
            local context = {
                buf = buf,
                view = setmetatable({ ranges = ranges }, View),
                conceal = { level = 0 },
            }
            wrapped = spy.on(Node, 'new')
            return Parser.new(context, { wrap = false }):parse(root, {})
        end

        it('wraps only a visible row and the off-screen delimiter', function()
            local data = parse({ { 10, 10 } })
            assert.is_not_nil(data)
            assert.same(1, data.delim.start_row)
            assert.same(1, #data.rows)
            assert.same(10, data.rows[1].node.start_row)
            assert.spy(wrapped).was_called(2)
        end)

        it(
            'retains rows from disjoint views and current overlap boundaries',
            function()
                local data = parse({ { 0, 0 }, { 10, 11 } })
                assert.is_not_nil(data)
                local rows = {}
                for _, item in ipairs(data.rows) do
                    rows[#rows + 1] = item.node.start_row
                end
                assert.same({ 0, 10, 11 }, rows)
                assert.spy(wrapped).was_called(4)
            end
        )

        it(
            'returns nil without visible rows but still retains the delimiter',
            function()
                assert.is_nil(parse({ { 100, 100 } }))
                assert.spy(wrapped).was_called(1)
                assert.stub(cols).was_not_called()
                assert.stub(row).was_not_called()
            end
        )
    end)

    it('distributes space largely evently', function()
        assert.same(
            { 8, 20, 20 },
            Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 48)
        )
        assert.same(
            { 4, 4, 3 },
            Parser.allocate({ 10, 10, 10 }, { 3, 3, 3 }, 11)
        )
        assert.same(
            { 4, 4, 4 },
            Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 12)
        )
        assert.same(
            { 8, 20, 60 },
            Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 100)
        )
        assert.same(nil, Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 11))
    end)

    it('breaks at word and token without losing highlights', function()
        local units = Parser.units({
            { 'abc def ', 'Normal' },
            { 'abcdefghij', 'String' },
        })
        assert.same({
            { { 'abc def', 'Normal' } },
            { { 'abcdefg', 'String' } },
            { { 'hij', 'String' } },
        }, Parser.wrap(units, 7))
    end)

    it('keeps composing characters and wide glyphs intact', function()
        local text = 'é行👩‍💻🇺🇸👍🏽'
        local units = Parser.units({ { text, 'String' } })
        local _, minimum = Parser.measure(units)
        local wrapped = Parser.wrap(units, minimum)
        local joined = ''
        for _, line in ipairs(wrapped) do
            assert.is_true(str.line_width(line) <= minimum)
            for _, chunk in ipairs(line) do
                joined = joined .. chunk[1]
            end
        end
        assert.same(text, joined)
        assert.same('é', units[1].text)
        assert.same('行', units[2].text)
    end)

    it('aligns each fragment including empty cells', function()
        local line = { { 'ab', 'String' } }
        assert.same(
            { { '   ', 'Normal' }, { 'ab', 'String' }, { ' ', 'Normal' } },
            Parser.align(line, 6, 'right', 1, 'Normal')
        )
        assert.same(
            { { '  ', 'Normal' }, { 'ab', 'String' }, { '  ', 'Normal' } },
            Parser.align(line, 6, 'center', 1, 'Normal')
        )
        assert.same(
            { { ' ', 'Normal' }, { '     ', 'Normal' } },
            Parser.align({}, 6, 'left', 1, 'Normal')
        )
        assert.same({ {} }, Parser.wrap({}, 1))
    end)
end)
