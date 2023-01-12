local telescope = require "commentalist.telescope"
local fonts = telescope.fonts

describe("font", function()
    it("requires bufnr arg", function()
        assert.error.matches(function()
            fonts { line1 = 1, line2 = -1 }
        end, "opts.bufnr must be specified")
    end)

    it("requires line1 arg", function()
        assert.error.matches(function()
            fonts { bufnr = 0, line2 = -1 }
        end, "opts.line1 must be specified")
    end)

    it("requires line2 arg", function()
        assert.error.matches(function()
            fonts { bufnr = 0, line1 = 1 }
        end, "opts.line2 must be specified")
    end)
end)
