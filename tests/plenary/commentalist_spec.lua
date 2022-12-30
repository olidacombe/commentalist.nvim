local commentalist = require("commentalist")
local comment = commentalist.comment
local load_fixture_to_new_buffer = require("tests.util").load_fixture_to_new_buffer
local assert_buffers_are_equal = require("tests.util").assert_buffers_are_equal

local fixtures = {
    ba_sh = {},
    comments_only_sh = {},
    hello_world_cpp = {},
    lib_rs = {},
}

local assert_fixture_expectation = function(fixture)
    local f = fixtures[fixture]
    assert_buffers_are_equal(f.commented_buf, f.orig_buf)
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
        local orig = load_fixture_to_new_buffer("comments_only.sh")
        local commented = load_fixture_to_new_buffer("comments_only_commented.sh")
        comment({ bufnr = orig, fargs = { "banner" } })
        assert_buffers_are_equal(commented, orig)
    end)

    it("comments a selection", function()
        comment({ bufnr = fixtures.hello_world_cpp.orig_buf, line1 = 3, line2 = 4, fargs = { "banner" } })
        assert_fixture_expectation("hello_world_cpp")
    end)

    it("comments different types of file", function()
        comment({ bufnr = fixtures.lib_rs.orig_buf, line1 = 1, line2 = 1, fargs = { "banner" } })
        assert_fixture_expectation("lib_rs")
        comment({ bufnr = fixtures.ba_sh.orig_buf, line1 = 5, line2 = 6, fargs = { "banner" } })
        assert_fixture_expectation("ba_sh")
    end)
end)
