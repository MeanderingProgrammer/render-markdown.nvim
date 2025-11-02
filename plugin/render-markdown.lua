local initialized = false
if initialized then
    return
end
initialized = true

-- Allow users to opt-in to lazy initialization by setting vim.g.render_markdown_lazy_init = true
-- When enabled, the plugin will not initialize until setup() is explicitly called
if vim.g.render_markdown_lazy_init then
    return
end

require('render-markdown').setup()
require('render-markdown.core.colors').init()
require('render-markdown.core.command').init()
require('render-markdown.core.log').init()
require('render-markdown.core.manager').init()
