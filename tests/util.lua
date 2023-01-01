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

local full_fixture_path = function(fixture)
    local utils_dir = debug.getinfo(2, "S").source:sub(2):match("(.*)/tests/") or "."
    return utils_dir .. "/tests/fixtures/" .. fixture
end

M.load_fixture_as_lines = function(fixture)
    return file_lines(full_fixture_path(fixture))
end

M.load_fixture_to_new_buffer = function(fixture)
    local filetype = require 'plenary.filetype'.detect(
        full_fixture_path(fixture)
    )
    local buf = vim.api.nvim_create_buf(false, false)
    local lines = M.load_fixture_as_lines(fixture)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_call(buf, function()
        vim.bo.filetype = filetype
    end)
    return buf
end

M.buffer_as_lines = function(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
end

M.assert_buffers_are_equal = function(buf1, buf2)
    assert.are.same(M.buffer_as_lines(buf1), M.buffer_as_lines(buf2))
end

return M
