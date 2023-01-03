local M = {}

M.render = function(lines, _)
    table.insert(lines, 1, "oi")
    return lines
end

return M
