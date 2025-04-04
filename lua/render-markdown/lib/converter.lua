---@class render.md.Converter
local M = {}

---@private
M.superscripts = {
    [' '] = ' ',
    ['('] = '⁽',
    [')'] = '⁾',

    ['0'] = '⁰',
    ['1'] = '¹',
    ['2'] = '²',
    ['3'] = '³',
    ['4'] = '⁴',
    ['5'] = '⁵',
    ['6'] = '⁶',
    ['7'] = '⁷',
    ['8'] = '⁸',
    ['9'] = '⁹',

    ['a'] = 'ᵃ',
    ['b'] = 'ᵇ',
    ['c'] = 'ᶜ',
    ['d'] = 'ᵈ',
    ['e'] = 'ᵉ',
    ['f'] = 'ᶠ',
    ['g'] = 'ᵍ',
    ['h'] = 'ʰ',
    ['i'] = 'ⁱ',
    ['j'] = 'ʲ',
    ['k'] = 'ᵏ',
    ['l'] = 'ˡ',
    ['m'] = 'ᵐ',
    ['n'] = 'ⁿ',
    ['o'] = 'ᵒ',
    ['p'] = 'ᵖ',
    ['q'] = nil,
    ['r'] = 'ʳ',
    ['s'] = 'ˢ',
    ['t'] = 'ᵗ',
    ['u'] = 'ᵘ',
    ['v'] = 'ᵛ',
    ['w'] = 'ʷ',
    ['x'] = 'ˣ',
    ['y'] = 'ʸ',
    ['z'] = 'ᶻ',

    ['A'] = 'ᴬ',
    ['B'] = 'ᴮ',
    ['C'] = nil,
    ['D'] = 'ᴰ',
    ['E'] = 'ᴱ',
    ['F'] = nil,
    ['G'] = 'ᴳ',
    ['H'] = 'ᴴ',
    ['I'] = 'ᴵ',
    ['J'] = 'ᴶ',
    ['K'] = 'ᴷ',
    ['L'] = 'ᴸ',
    ['M'] = 'ᴹ',
    ['N'] = 'ᴺ',
    ['O'] = 'ᴼ',
    ['P'] = 'ᴾ',
    ['Q'] = nil,
    ['R'] = 'ᴿ',
    ['S'] = nil,
    ['T'] = 'ᵀ',
    ['U'] = 'ᵁ',
    ['V'] = 'ⱽ',
    ['W'] = 'ᵂ',
    ['X'] = nil,
    ['Y'] = nil,
    ['Z'] = nil,
}

---@param s string
---@return string?
function M.superscript(s)
    local chars = {}
    for char in s:gmatch('.') do
        char = M.superscripts[char]
        if char == nil then
            return nil
        end
        chars[#chars + 1] = char
    end
    return table.concat(chars)
end

return M
