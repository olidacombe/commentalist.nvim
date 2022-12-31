local commentalist = require("commentalist")
local comment = commentalist.comment
local load_fixture_to_new_buffer = require("tests.util").load_fixture_to_new_buffer
local assert_buffers_are_equal = require("tests.util").assert_buffers_are_equal

local fixtures = {
    ba_sh = {},
    comments_only_sh = {},
    hello_world_cpp = {},
    lib_rs = {},
    raw_sh = {},
}

local assert_fixture_expectation = function(fixture)
    local f = fixtures[fixture]
    assert_buffers_are_equal(f.commented_buf, f.orig_buf)
end

-- TODO move to tests/fixtures/init.lua
local Fixture = {}
local CommentedFixture = {}

function Fixture:new(fixture)
    local obj = {}
    obj.buffer = load_fixture_to_new_buffer(fixture)
    local filename = fixture:gsub('\\.', "_commented.")
    obj.expected_buffer = load_fixture_to_new_buffer(filename)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Fixture:comment(args)
    local opts = {
        bufnr = self.buffer,
        fargs = { "banner" }
    }
    for k, v in pairs(args or {}) do
        opts[k] = v
    end
    comment(opts)
    return CommentedFixture:new(self)
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

describe("comment", function()
    before_each(function()
        for fixture, t in pairs(fixtures) do
            -- The "original" buffer, which our tests should
            -- mess with and compare with expectations
            local filename = fixture:gsub("(.*)_", "%1.")
            t.orig_buf = load_fixture_to_new_buffer(filename)
            -- This "expected" buffer might never get modified,
            -- so maybe we'll load it once and clean it up once
            -- in future
            filename = fixture:gsub("(.*)_", "%1_commented.")
            t.commented_buf = load_fixture_to_new_buffer(filename)
        end
    end)

    after_each(function()
        -- clean up all the fixture buffers
        for _, bufs in pairs(fixtures) do
            for _, buf in pairs(bufs) do
                vim.api.nvim_buf_delete(buf, { force = true })
            end
            bufs = {}
        end
    end)

    it("comments whole buffer by default", function()
        Fixture:new("raw.sh"):comment():assert()
        local orig = load_fixture_to_new_buffer("raw.sh")
        local commented = load_fixture_to_new_buffer("raw_commented.sh")
        vim.api.nvim_buf_call(orig, function()
            vim.bo.filetype = "sh"
        end)
        comment({ bufnr = orig, fargs = { "banner" } })
        assert_buffers_are_equal(commented, orig)
    end)

    it("re-comments commented text", function()
        local orig = load_fixture_to_new_buffer("comments_only.sh")
        vim.api.nvim_buf_call(orig, function()
            vim.bo.filetype = "sh"
        end)
        local commented = load_fixture_to_new_buffer("comments_only_commented.sh")
        comment({ bufnr = orig, fargs = { "banner" } })
        assert_buffers_are_equal(commented, orig)
    end)

    it("comments a selection", function()
        local orig = load_fixture_to_new_buffer("hello_world.cpp")
        vim.api.nvim_buf_call(orig, function()
            vim.bo.filetype = "cpp"
        end)
        comment({ bufnr = orig, line1 = 3, line2 = 4, fargs = { "banner" } })
        local commented = load_fixture_to_new_buffer("hello_world_commented.cpp")
        assert_buffers_are_equal(commented, orig)
    end)

    it("comments different types of file", function()
        local orig = load_fixture_to_new_buffer("lib.rs")
        vim.api.nvim_buf_call(orig, function()
            vim.bo.filetype = "rust"
        end)
        local commented = load_fixture_to_new_buffer("lib_commented.rs")
        comment({ bufnr = orig, line1 = 1, line2 = 1, fargs = { "banner" } })
        assert_buffers_are_equal(commented, orig)

        orig = load_fixture_to_new_buffer("ba.sh")
        vim.api.nvim_buf_call(orig, function()
            vim.bo.filetype = "sh"
        end)
        comment({ bufnr = orig, line1 = 5, line2 = 6, fargs = { "banner" } })
        local commented = load_fixture_to_new_buffer("ba_commented.sh")
        assert_buffers_are_equal(commented, orig)
    end)
end)
