local M = {}

local out = {}

local shell_render_job = function(cmdline_args, callback)
    vim.fn.jobstart(cmdline_args, {
        on_stdout = function(id, data, _)
            out[id] = out[id] or {}
            for _, v in ipairs(data) do
                table.insert(out[id], v)
            end
        end,
        on_exit   = function(id, _, _)
            callback(out[id])
        end
    })
end

local figlet = function(string, font, callback)
    local cmdline_args = { "figlet" }
    if font then
        table.insert(cmdline_args, "-f")
        table.insert(cmdline_args, font)
    end
    table.insert(cmdline_args, string)
    shell_render_job(cmdline_args, callback)
end

M.comment = function(opts)
    --P(opts)
    -- TODO offer all renderers, not just figlet
    figlet("bla", opts.fargs[1], function(output)
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(buf, opts.line1, opts.line2, false, output)
    end)
end

return M


-- hey
-- hello
