local shell_render_job = require("commentalist.renderers").shell_render_job

local M = {}

M.render = function(lines, font)
    -- TODO
    return lines
end

M.fonts = function(register)
    -- TODO, non-OSX variants
    -- ls $(brew --prefix toilet)/share/figlet | sed 's/\.[ft]lf$//'
end

return M
