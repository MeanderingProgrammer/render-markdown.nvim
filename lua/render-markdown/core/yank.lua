local env = require('render-markdown.lib.env')

---@class render.md.Yank
local M = {}

---yank the content of the code block under the cursor linewise, without the
---fences or the prefix of its container (list indent, block quote marker)
---@param register? string defaults to v:register
function M.code(register)
    local buf = env.buf.current()
    if not require('render-markdown.core.manager').attached(buf) then
        M.notify('buffer is not attached', vim.log.levels.WARN)
        return
    end
    local row, col = unpack(vim.api.nvim_win_get_cursor(env.win.current()))
    local block = M.block(buf, row - 1, col)
    if not block then
        M.notify('no code block under cursor', vim.log.levels.WARN)
        return
    end
    local lines = M.lines(buf, block)
    if #lines == 0 then
        M.notify('code block is empty', vim.log.levels.WARN)
        return
    end
    vim.fn.setreg(register or vim.v.register, lines, 'l')
    -- same message as a builtin linewise yank
    local plural = #lines == 1 and '' or 's'
    local message = ('%d line%s yanked'):format(#lines, plural)
    vim.api.nvim_echo({ { message } }, true, {})
end

---outermost code block containing the position, injections are ignored so a
---code block nested in a markdown code block yanks the outer one
---@private
---@param buf integer
---@param row integer
---@param col integer
---@return TSNode?
function M.block(buf, row, col)
    local ok, parser = pcall(vim.treesitter.get_parser, buf, 'markdown')
    if not ok or not parser then
        return nil
    end
    parser:parse({ row, row })
    local node = vim.treesitter.get_node({
        bufnr = buf,
        pos = { row, col },
        lang = 'markdown',
    })
    while node and node:type() ~= 'fenced_code_block' do
        node = node:parent()
    end
    return node
end

---@private
---@param buf integer
---@param block TSNode
---@return string[]
function M.lines(buf, block)
    -- content rows start after a block_continuation, which covers the prefix
    local content = nil ---@type TSNode?
    local prefixes = {} ---@type table<integer, integer>
    local function collect(node)
        for child in node:iter_children() do
            local kind = child:type()
            if kind == 'block_continuation' then
                local row, _, _, end_col = child:range()
                prefixes[row] = end_col
            elseif kind == 'code_fence_content' then
                content = child
                collect(child)
            end
        end
    end
    collect(block)
    if not content then
        return {}
    end
    local start_row, start_col, end_row, end_col = content:range()
    prefixes[start_row] = start_col
    -- content ends at the prefix of the closing fence row
    if end_col <= (prefixes[end_row] or 0) then
        end_row = end_row - 1
    end
    local lines = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)
    for i, line in ipairs(lines) do
        lines[i] = line:sub((prefixes[start_row + i - 1] or 0) + 1)
    end
    return lines
end

---@private
---@param message string
---@param level integer
function M.notify(message, level)
    vim.notify(('render-markdown.nvim: %s'):format(message), level)
end

return M
