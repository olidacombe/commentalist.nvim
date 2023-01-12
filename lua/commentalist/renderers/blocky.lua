--
-- _|        _|                      _|
-- _|_|_|    _|    _|_|      _|_|_|  _|  _|    _|    _|
-- _|    _|  _|  _|    _|  _|        _|_|      _|    _|
-- _|    _|  _|  _|    _|  _|        _|  _|    _|    _|
-- _|_|_|    _|    _|_|      _|_|_|  _|    _|    _|_|_|
--                                                   _|
--                                               _|_|
--
-- This is an example of a simple no-font renderer you
-- might write.
--
-- Enable with
-- ```lua
-- require("commentalist").setup({
--     renderers = {
--         blocky = require"commentalist.renderers.blocky"
--     }
-- })
-- ```
--
-- And `blocky` should become available in your rendeder
-- list when running `:Commentalist`.  Notice you're not
-- offered any fonts.

local M = {}

M._comment_char = function()
    local commentstring = vim.bo.commentstring
    commentstring = commentstring:gsub("%s*%%s.*", "")
    local _, _, c = commentstring:find "(.)$"
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
    local ret = { head_tail }
    for _, line in ipairs(lines) do
        table.insert(ret, line .. string.rep(" ", n + 1 - line:len()) .. c)
    end
    table.insert(ret, head_tail)
    return ret
end

return M
