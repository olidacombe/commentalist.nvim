local M = {}

M._comment_char = function()
    local commentstring = vim.bo.commentstring
    commentstring = commentstring:gsub("%s*%%s.*", "")
    local _, _, c = commentstring:find("(.)$")
    return c
end

M.render = function(lines, _)
    -- get max line length
    local n = 0
    for _, line in ipairs(lines) do
        n = math.max(n, line:len())
    end
    local c = M._comment_char()
    local head_tail = string.rep(c, n + 2)
    ret = { head_tail }
    for _, line in ipairs(lines) do
        table.insert(ret, line .. string.rep(" ", n + 1 - line:len()) .. c)
    end
    table.insert(ret, head_tail)
    return ret
end

return M
