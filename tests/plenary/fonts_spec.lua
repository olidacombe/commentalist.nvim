local fonts = require("commentalist.fonts")

describe("register", function()
    local register = fonts.register

    before_each(function()
        fonts._clear()
    end)

    it("registers a string", function()
        register("my cool font")
        assert.are.same(fonts.all(), { "my cool font" })
    end)

    it("registers a table", function()
        register({ "my cool font", "your cooler font" })
        assert.are.same(fonts.all(), { "my cool font", "your cooler font" })
    end)

    it("doesn't double register", function()
        register("font1")
        register("font1")
        register({ "font2", "font3" })
        register({ "font3", "font4" })
        assert.are.same(fonts.all(), { "font1", "font2", "font3", "font4" })
    end)
end)
