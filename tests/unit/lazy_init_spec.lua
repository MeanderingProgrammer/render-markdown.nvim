---@module 'luassert'

describe('lazy_init', function()
    ---Reset the module state between tests
    local function reset_module()
        -- Clear the loaded module cache to force re-initialization
        package.loaded['render-markdown'] = nil
        package.loaded['render-markdown.state'] = nil
        package.loaded['render-markdown.core.manager'] = nil
        package.loaded['render-markdown.core.colors'] = nil
        package.loaded['render-markdown.core.command'] = nil
        package.loaded['render-markdown.core.log'] = nil
    end

    it('defers initialization when lazy_init is true', function()
        reset_module()
        vim.g.render_markdown_lazy_init = true

        -- Load the module
        local rm = require('render-markdown')

        -- Module should not be initialized yet since we haven't called setup
        assert.equals(false, rm.initialized)

        -- Now call setup explicitly
        rm.setup({})

        -- Now it should be initialized
        assert.equals(true, rm.initialized)

        -- Cleanup
        vim.g.render_markdown_lazy_init = nil
    end)

    it('does not reinitialize on second setup call', function()
        reset_module()
        vim.g.render_markdown_lazy_init = true

        local rm = require('render-markdown')

        -- First setup
        rm.setup({ enabled = true })
        assert.equals(true, rm.initialized)

        local state = require('render-markdown.state')
        local first_enabled = state.enabled
        assert.equals(true, first_enabled)

        -- Second setup with empty config should not reinitialize
        rm.setup({})
        assert.equals(true, rm.initialized)

        -- State should remain the same
        assert.equals(first_enabled, state.enabled)

        -- Cleanup
        vim.g.render_markdown_lazy_init = nil
    end)
end)
