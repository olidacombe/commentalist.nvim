local health = vim.health or require "health"

local M = {}

local optional_binaries = {
    -- boxes
    "boxes",
    -- cowsay
    "cowsay",
    -- figlet
    "figlet",
    "figlist",
    -- toilet
    "toilet",
}

M.check = function()
    health.report_start "Checking for default renderers"
    for _, bin in ipairs(optional_binaries) do
        if vim.fn.executable(bin) == 1 then
            health.report_ok(("`%s` found"):format(bin))
        else
            health.report_warn(("`%s` not found"):format(bin))
        end
    end
end

return M
