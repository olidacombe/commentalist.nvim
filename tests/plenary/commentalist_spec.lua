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
