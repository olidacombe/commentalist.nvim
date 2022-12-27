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
    table.insert(cmdline_args, "--")
    table.insert(cmdline_args, string)
    shell_render_job(cmdline_args, callback)
end

M.comment = function(opts)
    --P(opts)
    local line1, line2 = opts.line1, opts.line2
    local buf = vim.api.nvim_get_current_buf()
    -- nvi_buf_get_lines Indexing is zero-based, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
    lines = table.concat(lines, "\n")
    P(lines)
    -- TODO offer all renderers, not just figlet
    figlet(lines, opts.fargs[1], function(output)
        vim.api.nvim_buf_set_lines(buf, line1, line2, false, output)
    end)
end

return M

-- hey
-- hello
