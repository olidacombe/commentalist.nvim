local comment_api = require("Comment.api")
local Job = require("plenary.job")

local M = {
    renderers = {
        figlet = {},
    },
}

local shell_render_job = function(cmdline_args, callback)
    local command = table.remove(cmdline_args, 1)
    local job = Job:new({
        command = command,
        args    = cmdline_args,
        on_exit = callback and function(j, _)
            callback(j:result())
        end
    })
    job:start()
    return job
end

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

M.setup = function()
    shell_render_job({ "figlist" }, function(figlist)
        M.renderers.figlet = filter_figlet_font_list(figlist)
    end)
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
    opts = opts or {}
    -- get variables
    opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
    local fargs = opts.fargs or {}
    local font = fargs[1]
    opts.line1 = opts.line1 or 1
    opts.line2 = opts.line2 or -1
    -- if no font has been sepecified, let the user select one
    if not font then
        -- TODO picker comes from config created at setup,
        -- and may not be telescope
        require("commentalist.telescope").fonts(opts)
        return
    end
    -- Otherwise we've been ginen a font, act

    local bufnr, line1, line2 = opts.bufnr, opts.line1, opts.line2

    -- Strip comments first
    vim.api.nvim_buf_call(bufnr, function()
        uncomment(line2 - line1 + 1)
    end)

    -- nvi_buf_get_lines Indexing is zero-based, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
    lines = table.concat(lines, "\n")

    -- TODO offer all renderers, not just figlet
    local ascii_render = figlet(lines, font)
    ascii_render:sync()
    local ascii = ascii_render:result()
    vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, ascii)
    -- TODO a more robust count of the output lines
    vim.api.nvim_buf_call(bufnr, function()
        comment(#ascii)
    end)
end

return M
