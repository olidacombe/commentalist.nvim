local shell_render_job = require("commentalist.renderers").shell_render_job

local M = {}

local filter_figlet_font_list = function(figlist)
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

local figlet = function(string, font)
    local cmdline_args = { "figlet" }
    if font then
        table.insert(cmdline_args, "-f")
        table.insert(cmdline_args, font)
    end
    table.insert(cmdline_args, "--")
    table.insert(cmdline_args, string)
    return shell_render_job(cmdline_args, nil)
end

M.render = figlet
M.fonts = function(register)
    shell_render_job({ "figlist" }, function(figlist)
        register(filter_figlet_font_list(figlist))
    end)
end

return M
