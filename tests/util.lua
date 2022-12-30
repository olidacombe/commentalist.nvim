local M = {}

local file_lines = function(filename)
    local file = io.open(filename, "r")
    local lines = {}
    if not file then return lines end
    for line in file:lines() do
        table.insert(lines, line)
    end
    return lines
end

M.load_fixture_as_lines = function(fixture)
    local utils_dir = debug.getinfo(2, "S").source:sub(2):match("(.*)/tests/") or "."
    local fixture_filename = utils_dir .. "/tests/fixtures/" .. fixture
    return file_lines(fixture_filename)
end

M.load_fixture_to_new_buffer = function(fixture)
    local buf = vim.api.nvim_create_buf(false, false)
    local lines = M.load_fixture_as_lines(fixture)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end

M.buffer_as_lines = function(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 1, -1, false)
end

M.assert_buffers_are_equal = function(buf1, buf2)
    assert.are.same(M.buffer_as_lines(buf1), M.buffer_as_lines(buf2))
end

return M
