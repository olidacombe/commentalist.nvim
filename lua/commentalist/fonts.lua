local M = {
    _fonts = {}
}

M._clear = function()
    M._fonts = {}
end

local _register_single_font = function(font)
    M._fonts[font] = true
end

M.register = function(registrand)
    local t = type(registrand)
    if t == "string" then
        _register_single_font(registrand)
    elseif t == "table" then
        for _, font in ipairs(registrand) do
            _register_single_font(font)
        end
    end
end

M.all = function()
    local fonts = {}
    for font, _ in pairs(M._fonts) do
        table.insert(fonts, font)
    end
    table.sort(fonts)
    return fonts
end

return M
