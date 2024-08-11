if vim.g.loaded_render_markdown then
    return
end
vim.g.loaded_render_markdown = true

vim.notify(
    [[
The markdown.nvim package has been renamed and receives no updates under the old name
Migrate to the new LuaRock render-markdown.nvim: https://luarocks.org/modules/MeanderingProgrammer/render-markdown.nvim
If you use rocks.nvim this can be done by running the following two commands:
  :Rocks prune markdown.nvim
  :Rocks install render-markdown.nvim
]],
    vim.log.levels.WARN
)

require('render-markdown').setup({})
require('render-markdown.colors').setup()
require('render-markdown.manager').setup()

vim.api.nvim_create_user_command('RenderMarkdown', function(opts)
    local args = opts.fargs
    if #args == 0 then
        require('render-markdown.api').enable()
    elseif #args == 1 then
        local command = require('render-markdown.api')[args[1]]
        if command ~= nil then
            command()
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
            return vim.tbl_keys(require('render-markdown.api'))
        else
            return {}
        end
    end,
})
