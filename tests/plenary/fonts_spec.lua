local fonts = require "commentalist.fonts"

describe("register", function()
    local register = fonts.register

    before_each(function()
        fonts._clear()
    end)

    it("registers a string", function()
        register("test", "my cool font")
        assert.are.same(fonts.all(), { "test/my cool font" })
    end)

    it("registers a table", function()
        register("test", { "my cool font", "your cooler font" })
        assert.are.same(fonts.all(), { "test/my cool font", "test/your cooler font" })
    end)

    it("doesn't double register", function()
        register("test", "font1")
        register("test", "font1")
        register("test", { "font2", "font3" })
        register("test", { "font3", "font4" })
        assert.are.same(fonts.all(), { "test/font1", "test/font2", "test/font3", "test/font4" })
    end)

    it("registers no-font renderers", function()
        register("blocky", nil)
        assert.are.same(fonts.all(), { "blocky" })
    end)
end)
