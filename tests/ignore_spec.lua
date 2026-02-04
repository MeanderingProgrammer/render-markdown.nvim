local util = require('tests.util')

describe('code ignore', function()
    it('ignores configured languages', function()
        util.setup.text({
            '```mermaid',
            'graph TD;',
            '    A-->B;',
            '```',
        }, {
            code = {
                ignore = { 'mermaid' },
            },
        })

        -- Should have no marks
        util.assert_marks({})
    end)

    it('ignores nothing by default', function()
        util.setup.text({
            '```mermaid',
            'graph TD;',
            '    A-->B;',
            '```',
        })

        util.assert_screen({
            'mermaid█████████████████████████████████████████████████████████████████████████',
            'graph TD;',
            '    A-->B;',
        })
    end)
end)