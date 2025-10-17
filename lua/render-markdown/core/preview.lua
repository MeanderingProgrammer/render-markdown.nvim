local env = require('render-markdown.lib.env')
local manager = require('render-markdown.core.manager')

---@class render.md.Preview
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('RenderMarkdownPreview', {})

---@private
---@type table<integer, integer>
M.buffers = {}

---@param buf integer
---@return integer?
function M.get(buf)
    for src, dst in pairs(M.buffers) do
        if buf == dst then
            return src
        end
    end
    return nil
end

---@param src_buf? integer
function M.open(src_buf)
    src_buf = src_buf or env.buf.current()
    if not manager.attached(src_buf) then
        return
    end
    if M.buffers[src_buf] then
        vim.api.nvim_buf_delete(M.buffers[src_buf], {})
        return
    end

    -- disable rendering for source buffer
    manager.set_buf(src_buf, false)

    local src_win = env.buf.win(src_buf)
    local dst_buf = vim.api.nvim_create_buf(false, true)
    local dst_win = vim.api.nvim_open_win(dst_buf, false, {
        split = 'right',
    })
    M.buffers[src_buf] = dst_buf

    env.buf.set(dst_buf, 'bufhidden', 'wipe')
    env.buf.set(dst_buf, 'buftype', 'nofile')
    env.buf.set(dst_buf, 'filetype', env.buf.get(src_buf, 'filetype'))
    env.buf.set(dst_buf, 'modifiable', false)
    env.buf.set(dst_buf, 'swapfile', false)

    M.copy_lines(src_buf, dst_buf)
    M.copy_cursor(src_win, dst_win)

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = M.group,
        buffer = src_buf,
        callback = function(args)
            if env.valid(src_buf, src_win) and env.valid(dst_buf, dst_win) then
                M.copy_cursor(src_win, dst_win)
                M.copy_event(args, dst_buf)
            end
        end,
    })

    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        group = M.group,
        buffer = src_buf,
        callback = function(args)
            if env.valid(src_buf, src_win) and env.valid(dst_buf, dst_win) then
                -- also need to copy cursor due to event ordering
                M.copy_lines(src_buf, dst_buf)
                M.copy_cursor(src_win, dst_win)
                M.copy_event(args, dst_buf)
            end
        end,
    })

    vim.api.nvim_create_autocmd('BufWipeout', {
        group = M.group,
        buffer = dst_buf,
        once = true,
        callback = function()
            M.buffers[src_buf] = nil
            vim.api.nvim_clear_autocmds({ group = M.group, buffer = src_buf })
            -- enable rendering for source buffer
            manager.set_buf(src_buf, true)
        end,
    })
end

---@private
---@param src integer
---@param dst integer
function M.copy_lines(src, dst)
    local src_lines = vim.api.nvim_buf_get_lines(src, 0, -1, false)
    local dst_lines = vim.api.nvim_buf_get_lines(dst, 0, -1, false)

    local src_text = table.concat(src_lines, '\n') .. '\n'
    local dst_text = table.concat(dst_lines, '\n') .. '\n'
    local diff = vim.diff(dst_text, src_text, { result_type = 'indices' })
    assert(type(diff) == 'table', 'diff must provide indices')

    env.buf.set(dst, 'modifiable', true)
    for i = 1, #diff do
        local hunk = diff[#diff - i + 1]
        local start_a, count_a, start_b, count_b = unpack(hunk)
        local line_start = start_a - 1
        local line_end = start_a + count_a - 1
        if count_a == 0 then
            line_start = line_start + 1
            line_end = line_end + 1
        end
        vim.api.nvim_buf_set_lines(dst, line_start, line_end, false, {
            unpack(src_lines, start_b, start_b + count_b - 1),
        })
    end
    env.buf.set(dst, 'modifiable', false)
end

---@private
---@param src integer
---@param dst integer
function M.copy_cursor(src, dst)
    local cursor = vim.api.nvim_win_get_cursor(src)
    pcall(vim.api.nvim_win_set_cursor, dst, cursor)
end

---@private
---@param args vim.api.keyset.create_autocmd.callback_args
---@param buf integer
function M.copy_event(args, buf)
    vim.api.nvim_exec_autocmds(args.event, { buffer = buf })
end

return M
