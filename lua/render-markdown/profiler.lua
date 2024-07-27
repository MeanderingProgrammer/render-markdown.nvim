local util = require('render-markdown.util')

---@class render.md.OutputResultStat
---@field n integer
---@field min number
---@field max number
---@field sum number
---@field mean number

---@class render.md.OutputStat
---@field path string
---@field size number
---@field results table<string, render.md.OutputResultStat>

---buffer -> result_state -> times
---@type table<integer, table<string, number[]>>
local stats = {}

---@class render.md.Profiler
local M = {}

---@param buf integer
---@param f fun(): string
function M.profile(buf, f)
    local start_ns = vim.uv.hrtime()
    local result = f()
    local time = (vim.uv.hrtime() - start_ns) / 1e+6

    if stats[buf] == nil then
        stats[buf] = {}
    end
    local buf_stats = stats[buf]
    if buf_stats[result] == nil then
        buf_stats[result] = {}
    end
    local times = buf_stats[result]
    table.insert(times, time)
end

function M.dump_stats()
    local output_stats = {}
    for buf, buf_stats in pairs(stats) do
        local results = {}
        for name, times in pairs(buf_stats) do
            results[name] = M.compute_stats(times)
        end
        ---@type render.md.OutputStat
        local output_stat = {
            path = util.file_path(buf),
            size = util.file_size_mb(buf),
            results = results,
        }
        table.insert(output_stats, output_stat)
    end
    if #output_stats > 0 then
        local file = assert(io.open('stats.json', 'w'))
        file:write(vim.fn.json_encode(output_stats))
        file:close()
    end
end

---@private
---@param times number[]
---@return render.md.OutputResultStat
function M.compute_stats(times)
    local min = times[1]
    local max = 0
    local sum = 0
    for _, time in ipairs(times) do
        min = math.min(min, time)
        max = math.max(max, time)
        sum = sum + time
    end
    ---@type render.md.OutputResultStat
    return {
        n = #times,
        min = min,
        max = max,
        sum = sum,
        mean = sum / #times,
    }
end

return M
