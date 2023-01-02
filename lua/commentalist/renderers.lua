local M = {
    _renderers = {}
}

local noop_renderer = function(lines)
    return lines
end

-- Takes a renderer/font repr and returns
-- renderer_name (string), font (string)
M._split_renderer_repr = function(repr)
    local _, _, renderer, font = repr:find("([^/]*)/?(.*)")
    if font == "" then font = nil end
    return renderer, font
end

M.get = function(repr)
    local renderer, font = M._split_renderer_repr(repr)
    renderer = M._renderers[renderer]

    return renderer and function(lines)
        return renderer(lines, font)
    end or noop_renderer
end

M.register = function(name, renderer)
    M._renderers[name] = renderer
end

return M
