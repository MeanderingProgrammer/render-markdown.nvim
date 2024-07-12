local state = require('render-markdown.state')
local util = require('render-markdown.util')

---@class render.md.handler.Shared
local M = {}

---When adding links to table cells we shift the text which can mess up alignment
---As a result table rendering needs to be painfully aware of this logic
---@param info render.md.NodeInfo
---@return string?
M.link_icon = function(info)
    local link = state.config.link
    if not link.enabled then
        return nil
    end
    -- Requires inline extmarks
    if not util.has_10 then
        return nil
    end
    if info.type == 'inline_link' then
        return link.hyperlink
    elseif info.type == 'image' then
        return link.image
    else
        return nil
    end
end

return M
