if vim.g.loaded_render_markdown then
    return
end
vim.g.loaded_render_markdown = true

require('render-markdown').setup({})
require('render-markdown.colors').setup()
require('render-markdown.manager').setup()

vim.api.nvim_create_user_command('RenderMarkdown', function(opts)
    local args = opts.fargs
    if #args == 0 then
        require('render-markdown.api').enable()
    elseif #args == 1 then
        if args[1] == 'enable' then
            require('render-markdown.api').enable()
        elseif args[1] == 'disable' then
            require('render-markdown.api').disable()
        elseif args[1] == 'toggle' then
            require('render-markdown.api').toggle()
        else
            vim.notify('markdown.nvim: unexpected command: ' .. args[1], vim.log.levels.ERROR)
        end
    else
        vim.notify('markdown.nvim: unexpected # arguments: ' .. #args, vim.log.levels.ERROR)
    end
end, {
    nargs = '*',
    desc = 'markdown.nvim commands',
    complete = function(_, cmdline)
        if cmdline:find('RenderMarkdown%s+%S+%s+.*') then
            return {}
        elseif cmdline:find('RenderMarkdown%s+') then
            return { 'enable', 'disable', 'toggle' }
        else
            return {}
        end
    end,
})
