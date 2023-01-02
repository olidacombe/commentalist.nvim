local comment_api = require("Comment.api")
local fonts = require("commentalist.fonts")
local renderers = require("commentalist.renderers")

local M = {
    renderers = {
        figlet = {},
    },
}

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
            table.insert(fonts, "figlet/" .. s)
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
    return renderers.shell_render_job(cmdline_args, nil)
end

M.defaults = {
    renderers = {
        blocky = {
            render = function(lines, _)
                return lines
            end
            -- fonts = function -> table | table | nil
        },
        -- TODO move to module
        figlet = {
            render = figlet,
            fonts = M.renderers.figlet
        }
    }
}

M.setup = function(opts)
    renderers.register("figlet", figlet)
    renderers.shell_render_job({ "figlist" }, function(figlist)
        -- M.renderers.figlet = filter_figlet_font_list(figlist)
        fonts.register(filter_figlet_font_list(figlist))
    end)
end

local cursor_stack = function(buf, line, col, callback)
    local win = 0
    local orig_buf = vim.api.nvim_get_current_buf()
    local orig_cursor = vim.api.nvim_win_get_cursor(win)

    if buf then
        vim.api.nvim_win_set_buf(win, buf)
    end
    vim.api.nvim_win_set_cursor(win, { line, col })

    callback()

    vim.api.nvim_win_set_cursor(win, orig_cursor)
    vim.api.nvim_win_set_buf(win, orig_buf)
end

local uncomment = function(line1, line2)
    cursor_stack(nil, line1, 0, function()
        -- TODO just uncomment either type, and not error
        -- when an uncomment fails (because it wasn't a comment
        -- or a particular type of comment
        comment_api.uncomment.linewise.count(line2 - line1 + 1)
    end)
end

local comment = function(line1, line2)
    cursor_stack(nil, line1, 0, function()
        comment_api.comment.linewise.count(line2 - line1 + 1)
    end)
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
        uncomment(line1, line2)
    end)

    -- nvim_buf_get_lines Indexing is zero-based, end-exclusive.
    local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
    lines = table.concat(lines, "\n")

    -- TODO offer all renderers, not just figlet
    -- local ascii_render = figlet(lines, font)
    local ascii_render = renderers.get(font)(lines)
    ascii_render:sync()
    local ascii = ascii_render:result()
    vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, ascii)
    -- TODO a more robust count of the output lines
    vim.api.nvim_buf_call(bufnr, function()
        comment(line1, line1 + #ascii - 1)
    end)
end

return M
