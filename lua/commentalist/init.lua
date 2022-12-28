local comment_api = require("Comment.api")

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

local uncomment = function(n_lines)
    -- TODO just uncomment either type, and not error
    -- when an uncomment fails (because it wasn't a comment
    -- or a particular type of comment
    comment_api.uncomment.linewise.count(n_lines)
end

local comment = function(n_lines)
    comment_api.comment.linewise.count(n_lines)
end

M.comment = function(opts)
    local bufnr, line1, line2 = opts.bufnr, opts.line1, opts.line2

    -- Strip comments first
    vim.api.nvim_buf_call(bufnr, function()
        uncomment(line2 - line1 + 1)
    end)

    -- nvi_buf_get_lines Indexing is zero-based, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
    lines = table.concat(lines, "\n")
    -- TODO offer all renderers, not just figlet
    figlet(lines, opts.fargs[1], function(output)
        vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, output)
        -- TODO a more robust count of the output lines
        vim.api.nvim_buf_call(bufnr, function()
            comment(vim.api.nvim_buf_line_count(0))
        end)
        -- comment(#output)
    end)
end

M.bla = function(opts)
    vim.api.nvim_buf_set_lines(opts.bufnr, -1, -1, false, { "something", "nice" })
end

return M
