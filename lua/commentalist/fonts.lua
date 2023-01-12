local M = {
    _fonts = {}
}

M._clear = function()
    M._fonts = {}
end

local _register_single_font = function(renderer, font)
    local repr = table.concat({ renderer, font }, "/")
    M._fonts[repr] = true
end

M.register = function(renderer, registrand)
    local t = type(registrand)
    if t == "string" then
        _register_single_font(renderer, registrand)
    elseif t == "table" then
        for _, font in ipairs(registrand) do
            _register_single_font(renderer, font)
        end
    elseif t == "function" then
        -- user has provided a function(register_callback)
        registrand(function(r) M.register(renderer, r) end)
    elseif t == "nil" then
        _register_single_font(renderer, nil)
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
