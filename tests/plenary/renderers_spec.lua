local renderers = require "commentalist.renderers"
local Fixture = require "tests.fixtures"

describe("split_renderer_repr", function()
    local split_renderer_repr = renderers._split_renderer_repr

    it("splits `figlet/banner` to `figlet`, `banner`", function()
        local r, f = split_renderer_repr "figlet/banner"
        assert.are.same(r, "figlet")
        assert.are.same(f, "banner")
    end)

    it("splits `rendy/font/with/slashes` to `rendy`, `font/with/slashes`", function()
        local r, f = split_renderer_repr "rendy/font/with/slashes"
        assert.are.same(r, "rendy")
        assert.are.same(f, "font/with/slashes")
    end)

    it("splits `rendy` to `rendy`, nil (for renderers without fonts)", function()
        local r, f = split_renderer_repr "rendy"
        assert.are.same(r, "rendy")
        assert.are.same(f, nil)
    end)
end)

describe("renderers.get", function()
    local register_renderer = renderers.register
    local get = renderers.get

    before_each(function()
        register_renderer("test", function(lines, font)
            local ret = {}
            for i, line in ipairs(lines) do
                ret[i] = font .. ":" .. line
            end
            return ret
        end)
    end)

    it("returns a no-op renderer on miss", function()
        local renderer = get "miss"
        assert.are.not_same(renderer, nil)
        local lines = { "untouched" }
        assert.are.same(renderer(lines), { "untouched" })
    end)

    it("curries the font", function()
        local renderer = get "test/fonty"
        local lines = { "liney" }
        assert.are.same(renderer(lines), { "fonty:liney" })
    end)
end)

-- just test some bits around the "example renderer"
describe("blocky._comment_char", function()
    local char = require("commentalist.renderers.blocky")._comment_char
    it("gets * for .cpp", function()
        local c = Fixture:new("hello_world.cpp"):bufdo(char)
        assert.are.same(c, "*")
    end)

    it("gets # for .sh", function()
        local c = Fixture:new("ba.sh"):bufdo(char)
        assert.are.same(c, "#")
    end)

    it("gets - for .lua", function()
        local c = Fixture:new("sol.lua"):bufdo(char)
        assert.are.same(c, "-")
    end)

    it("gets / for .rs", function()
        local c = Fixture:new("lib.rs"):bufdo(char)
        assert.are.same(c, "/")
    end)
end)
