local Job = require("plenary.job")

local M = {}

local filter_fonts = function(figlist)
    local fonts_start = false
    local fonts = {}
    for _, s in ipairs(figlist) do repeat
            if s:find("Figlet fonts in this directory:") then
                fonts_start = true
                break
            end
            if not fonts_start then
                break
            end
            if s:find("Figlet control files in this directory:") then
                return fonts
            end
            table.insert(fonts, s)
        until true
    end
    return fonts
end

M.render = function(lines, font)
    local args = {}
    if font then
        table.insert(args, "-f")
        table.insert(args, font)
    end
    local job = Job:new({
        command = "figlet",
        args = args,
        writer = lines,
    })
    job:start()
    return job
end

M.fonts = function(register)
    Job:new({
        command = "figlist",
        on_exit = function(j, _)
            register(filter_fonts(j:result()))
        end,
    }):start()
end

return M
