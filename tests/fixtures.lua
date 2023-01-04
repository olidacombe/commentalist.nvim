local commentalist = require("commentalist")
local comment = commentalist.comment
local load_fixture_to_new_buffer = require("tests.util").load_fixture_to_new_buffer
local assert_buffers_are_equal = require("tests.util").assert_buffers_are_equal

local Fixture = {}
local CommentedFixture = {}

function Fixture:new(fixture)
    local obj = {}
    obj.buffer = load_fixture_to_new_buffer(fixture)
    local filename = fixture:gsub('%.', "_commented.")
    obj.expected_buffer = load_fixture_to_new_buffer(filename)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Fixture:comment(args)
    local opts = {
        bufnr = self.buffer,
        fargs = { "figlet/banner" }
    }
    for k, v in pairs(args or {}) do
        opts[k] = v
    end
    comment(opts)
    return CommentedFixture:new(self)
end

function Fixture:bufdo(fn)
    -- execute fn() in buffer
    local ret = nil
    vim.api.nvim_buf_call(self.buffer, function()
        ret = fn()
    end)
    return ret
end

function CommentedFixture:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CommentedFixture:assert()
    -- raise if modified buffer is not equal to expected buffer
    assert_buffers_are_equal(self.expected_buffer, self.buffer)
end

return Fixture
