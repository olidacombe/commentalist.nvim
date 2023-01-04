local shell_render_job = require("commentalist.renderers").shell_render_job

local M = {}

M.render = function(lines, font)
    -- TODO
    return lines
end

M.fonts = function(register)
    -- TODO
    -- cowsay -l | sed -E '1d;s/[[:blank:]]+/\n/g'
end

return M
