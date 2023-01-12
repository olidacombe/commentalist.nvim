local Job = require "plenary.job"

local M = {}

M.render = function(lines, font)
    local job = Job:new {
        command = "cowsay",
        args = { "-f", font },
        writer = lines,
    }
    job:start()
    return job
end

local filter_fonts = function(lines)
    -- cowsay -l | sed -E '1d;s/[[:blank:]]+/\n/g'
    local fonts = {}
    for i, line in ipairs(lines) do
        -- we only want to skip the first line
        if i > 1 then
            for font in string.gmatch(line, "%S+") do
                table.insert(fonts, font)
            end
        end
    end
    return fonts
end

M.fonts = function(register)
    Job:new({
        command = "cowsay",
        args = { "-l" },
        on_exit = function(j, _)
            register(filter_fonts(j:result()))
        end,
    }):start()
end

return M
