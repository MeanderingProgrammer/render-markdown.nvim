---@class (exact) render.md.table.Config: render.md.base.Config
---@field preset render.md.table.Preset
---@field style render.md.table.Style
---@field cell render.md.table.Cell
---@field padding integer
---@field min_width integer
---@field border string[]
---@field border_virtual boolean
---@field alignment_indicator string
---@field head string
---@field row string
---@field filler string

---@enum render.md.table.Preset
local Preset = {
    none = 'none',
    round = 'round',
    double = 'double',
    heavy = 'heavy',
}

---@enum render.md.table.Style
local Style = {
    full = 'full',
    normal = 'normal',
    none = 'none',
}

---@enum render.md.table.Cell
local Cell = {
    trimmed = 'trimmed',
    padded = 'padded',
    raw = 'raw',
    overlay = 'overlay',
}

---@class render.md.table.Cfg
local M = {}

---@type render.md.table.Config
M.default = {
    -- Turn on / off pipe table rendering.
    enabled = true,
    -- Additional modes to render pipe tables.
    render_modes = false,
    -- Pre configured settings largely for setting table border easier.
    -- | heavy  | use thicker border characters     |
    -- | double | use double line border characters |
    -- | round  | use round border corners          |
    -- | none   | does nothing                      |
    preset = 'none',
    -- Determines how the table as a whole is rendered.
    -- | none   | disables all rendering                                                  |
    -- | normal | applies the 'cell' style rendering to each row of the table             |
    -- | full   | normal + a top & bottom line that fill out the table when lengths match |
    style = 'full',
    -- Determines how individual cells of a table are rendered.
    -- | overlay | writes completely over the table, removing conceal behavior and highlights |
    -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
    -- | padded  | raw + cells are padded to maximum visual width for each column             |
    -- | trimmed | padded except empty space is subtracted from visual width calculation      |
    cell = 'padded',
    -- Amount of space to put between cell contents and border.
    padding = 1,
    -- Minimum column width to use for padded or trimmed cell.
    min_width = 0,
    -- Characters used to replace table border.
    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal.
    -- stylua: ignore
    border = {
        '┌', '┬', '┐',
        '├', '┼', '┤',
        '└', '┴', '┘',
        '│', '─',
    },
    -- Always use virtual lines for table borders instead of attempting to use empty lines.
    -- Will be automatically enabled if indentation module is enabled.
    border_virtual = false,
    -- Gets placed in delimiter row for each column, position is based on alignment.
    alignment_indicator = '━',
    -- Highlight for table heading, delimiter, and the line above.
    head = 'RenderMarkdownTableHead',
    -- Highlight for everything else, main table rows and the line below.
    row = 'RenderMarkdownTableRow',
    -- Highlight for inline padding used to add back concealed space.
    filler = 'RenderMarkdownTableFill',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    local Base = require('render-markdown.config.base')
    Base.validate(spec)
    spec:one_of('preset', vim.tbl_values(Preset))
    spec:one_of('style', vim.tbl_values(Style))
    spec:one_of('cell', vim.tbl_values(Cell))
    spec:type('padding', 'number')
    spec:type('min_width', 'number')
    spec:list('border', 'string')
    spec:type('border_virtual', 'boolean')
    spec:type('alignment_indicator', 'string')
    spec:type('head', 'string')
    spec:type('row', 'string')
    spec:type('filler', 'string')
    spec:check()
end

return M
