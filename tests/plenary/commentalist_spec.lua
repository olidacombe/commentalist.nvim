local Fixture = require("tests.fixtures")
local commentalist = require("commentalist")

describe("comment", function()
    before_each(function()
        commentalist.setup()
    end)

    it("comments whole buffer by default", function()
        Fixture:new("raw.sh"):comment():assert()
    end)

    it("re-comments commented text", function()
        Fixture:new("comments_only.sh"):comment():assert()
    end)

    it("comments a selection", function()
        Fixture:new("hello_world.cpp"):comment({ line1 = 3, line2 = 4 }):assert()
    end)

    it("comments different types of file", function()
        Fixture:new("lib.rs"):comment({ line1 = 1, line2 = 1 }):assert()
        Fixture:new("ba.sh"):comment({ line1 = 5, line2 = 6 }):assert()
    end)
end)

describe("setup", function()
    local setup = commentalist.setup
    local renderers = require("commentalist.renderers")._renderers

    local clear_renderers = function()
        for k, _ in pairs(renderers) do renderers[k] = nil end
    end

    it("requires renderers entries to have a render method", function()
        assert.error.matches(function() setup({
                renderers = {
                    invalid = {}
                }
            })
        end, "no render funtion specified for renderer `invalid`")
    end)

    it("disables renderers via setup", function()
        clear_renderers()
        setup()
        assert(renderers["cowsay"])
        clear_renderers()
        setup({
            renderers = {
                cowsay = false
            }
        })
        assert.are.same(renderers["cowsay"], nil)
    end)
end)
