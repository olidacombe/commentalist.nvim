local M = {
    _fonts = {}
}

M._clear = function()
    M._fonts = {}
end

local _register_single_font = function(renderer, font)
    M._fonts[renderer .. "/" .. font] = true
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
        registrand(function(registrand) M.register(renderer, registrand) end)
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
