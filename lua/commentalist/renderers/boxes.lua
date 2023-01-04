local Job = require("plenary.job")

local M = {}

M.render = function(lines, font)
    local job = Job:new({
        command = "boxes",
        args = { "-a", "hcvc", "-d", font },
        writer = lines,
    })
    job:start()
    return job
end

local filter_fonts = function(lines)
    -- boxes -l | grep -e "^[^[:blank:]]" | sed '1d;2d;$d' | awk 'NR%2==1 { print }'
    local ret = {}
    local next = nil
    local skip = false
    for i, line in ipairs(lines) do
        if i > 2 and line:find('^[^%s]') then
            if not skip then
                -- inserting nil has no effect :)
                table.insert(ret, next)
                next = line
            end
            skip = not skip
        end
    end
    return ret
end

M.fonts = function(register)
    Job:new({
        command = "boxes",
        args = { "-l" },
        on_exit = function(j, _)
            register(filter_fonts(j:result()))
        end,
    }):start()
end

return M
