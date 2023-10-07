---@param str string
---@param separator string
---@param withpattern? boolean
local function split(str, separator, withpattern)
    withpattern = withpattern or false

    local result = {}
    local current_pos = 1

    for i = 1, #str do
        local start_pos, end_pos = str:find(separator, current_pos, not withpattern)
        if not start_pos then break end

        result[i] = str:sub(current_pos, start_pos - 1)
        current_pos = end_pos + 1
    end

    result[#result + 1] = str:sub(current_pos)

    return result
end

return { split = split }
